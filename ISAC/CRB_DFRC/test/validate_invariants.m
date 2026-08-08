function validate_invariants()
%VALIDATE_INVARIANTS Phase 11 automated validation suite (CVX-free modules).
%
%   Runs every numerical invariant flagged throughout Phases 3/7/8 that
%   does NOT require CVX (i.e. covers utilities/, initialization/, and
%   the two closed-form algorithms pointtarget_singleuser.m and
%   extended_singleuser.m). The four CVX-dependent modules
%   (pointtarget_multiuser_sdr, extended_multiuser_sdr, design1_sdr,
%   design2_sdr) are NOT exercised here -- they require a real CVX
%   installation and are validated separately by running Fig. 2 itself
%   (the closed-form-vs-CVX self-consistency check IS the validation
%   for those paths) under MATLAB+CVX.
%
%   This script is engine-agnostic: it runs under both MATLAB and
%   GNU Octave (>= 6), since none of the CVX-free modules use any
%   MATLAB-only toolbox functions beyond qr/eig/svd/null, which Octave
%   implements compatibly.
%
%   Run: validate_invariants()   (prints PASS/FAIL per check, and a
%                                  final summary; errors out with a
%                                  nonzero exit-relevant message if any
%                                  check fails)
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026
    proj_root = fileparts(fileparts(mfilename('fullpath')));
    addpath(genpath(proj_root));

    results = struct('name', {}, 'passed', {}, 'detail', {});
    tol = 1e-8;

    fprintf('=== Phase 11 Validation Suite (CVX-free modules) ===\n\n');

    % -----------------------------------------------------------------
    % CHECK 1: steering vector orthogonality, Re{a'*adot} = 0 (Eq. 21
    % clarification -- exact for real part, not for the full complex
    % inner product)
    % -----------------------------------------------------------------
    Nt_test = 16; d_spacing = 0.5;
    for theta_deg = [-60 -30 -10 0 10 30 60]
        theta_rad = deg2rad(theta_deg);
        [a_vec, adot_vec] = steering_vectors(theta_rad, Nt_test, d_spacing);
        val = abs(real(a_vec'*adot_vec));
        ok = val < tol;
        results(end+1) = struct('name', sprintf('Eq.21 orthogonality (theta=%d deg)', theta_deg), ...
            'passed', ok, 'detail', sprintf('|Re{a''adot}| = %.3e', val)); %#ok<AGROW>
    end

    % Also check ||a||^2 == Nt (unit-modulus elements)
    [a_vec, ~] = steering_vectors(deg2rad(17), Nt_test, d_spacing);
    ok = abs(norm(a_vec)^2 - Nt_test) < tol;
    results(end+1) = struct('name', '||a(theta)||^2 == Nt', 'passed', ok, ...
        'detail', sprintf('||a||^2 = %.6f (expected %d)', norm(a_vec)^2, Nt_test));

    % -----------------------------------------------------------------
    % CHECK 2: generate_channel produces unit-power i.i.d. entries
    % (statistical check, large sample, loose tolerance)
    % -----------------------------------------------------------------
    rng(123);
    Hbig = generate_channel(1000, 50);
    avg_power = mean(abs(Hbig(:)).^2);
    ok = abs(avg_power - 1) < 0.05;   % statistical tolerance
    results(end+1) = struct('name', 'generate_channel unit average power', 'passed', ok, ...
        'detail', sprintf('mean|H|^2 = %.4f (expected ~1.0)', avg_power));

    % -----------------------------------------------------------------
    % CHECK 3: pointtarget_singleuser (Theorem 1) invariants
    % -----------------------------------------------------------------
    rng(7);
    Nt_test = 16;
    [a_vec, ~] = steering_vectors(deg2rad(0), Nt_test, 0.5);
    PT = 1.0; sigmaC2 = 1.0;

    % Case: SINR constraint ACTIVE (force by picking Gamma1 as a
    % fraction of the FEASIBILITY LIMIT, PT*||h1||^2/sigmaC2, so the
    % test is guaranteed feasible regardless of the random h1 drawn,
    % while still comfortably exceeding the inactive-branch threshold
    % PT*|h1'a|^2/(Nt*sigmaC2) for a generic (uncorrelated) h1/a pair)
    h1 = (randn(Nt_test,1)+1i*randn(Nt_test,1))/sqrt(2);
    feas_limit = PT*norm(h1)^2/sigmaC2;
    Gamma1_active = 0.9 * feas_limit;   % 90% of the feasibility ceiling: feasible with margin, robustly forces the active branch
    [w1, diagA] = pointtarget_singleuser(a_vec, h1, Gamma1_active, sigmaC2, PT);
    if diagA.feasible && strcmp(diagA.case_used,'active')
        sinr_achieved = abs(h1'*w1)^2 / sigmaC2;
        ok = strcmp(diagA.case_used, 'active') && abs(sinr_achieved - Gamma1_active) < 1e-4*Gamma1_active;
        results(end+1) = struct('name', 'Theorem 1 Case 2 (active): SINR met with equality', ...
            'passed', ok, 'detail', sprintf('achieved=%.4f target=%.4f case=%s', sinr_achieved, Gamma1_active, diagA.case_used));

        ok2 = abs(norm(w1)^2 - PT) < 1e-6;
        results(end+1) = struct('name', 'Theorem 1 Case 2 (active): full power used', ...
            'passed', ok2, 'detail', sprintf('||w1||^2 = %.6f (expected PT=%.2f)', norm(w1)^2, PT));
    else
        results(end+1) = struct('name', 'Theorem 1 Case 2 (active) setup', 'passed', false, ...
            'detail', 'Test point turned out infeasible; adjust Gamma1_active in test.');
    end

    % Case: SINR constraint INACTIVE (small Gamma, well-aligned h1~a)
    h1_aligned = a_vec + 0.01*(randn(Nt_test,1)+1i*randn(Nt_test,1));
    Gamma1_inactive = 1e-6;
    [w1b, diagB] = pointtarget_singleuser(a_vec, h1_aligned, Gamma1_inactive, sigmaC2, PT);
    ok = diagB.feasible && strcmp(diagB.case_used, 'inactive') && abs(norm(w1b)^2 - PT) < 1e-6;
    results(end+1) = struct('name', 'Theorem 1 Case 1 (inactive): full power to radar direction', ...
        'passed', ok, 'detail', sprintf('case=%s ||w1||^2=%.4f', diagB.case_used, norm(w1b)^2));

    % Infeasibility detection
    [~, diagC] = pointtarget_singleuser(a_vec, h1, 1e12, sigmaC2, PT);
    ok = ~diagC.feasible;
    results(end+1) = struct('name', 'Theorem 1 infeasibility correctly detected', 'passed', ok, ...
        'detail', sprintf('feasible=%d (expected 0)', diagC.feasible));

    % -----------------------------------------------------------------
    % CHECK 4: extended_singleuser (Theorem 3) invariants
    % -----------------------------------------------------------------
    rng(11);
    h1e = (randn(Nt_test,1)+1i*randn(Nt_test,1))/sqrt(2);
    Gamma1e = 5;
    [WC, WA, diagE] = extended_singleuser(h1e, Gamma1e, sigmaC2, PT, Nt_test);
    if diagE.feasible
        RX = WC*WC' + WA*WA';
        ok = abs(real(trace(RX)) - PT) < 1e-6;
        results(end+1) = struct('name', 'Theorem 3: power budget met with equality', 'passed', ok, ...
            'detail', sprintf('tr(RX) = %.6f (expected PT=%.2f)', real(trace(RX)), PT));

        r = rcond(RX);
        ok2 = r > 1e-8;
        results(end+1) = struct('name', 'Theorem 3: RX is full rank (extended-target augmentation works)', ...
            'passed', ok2, 'detail', sprintf('rcond(RX) = %.3e', r));

        if strcmp(diagE.regime_used, 'active')
            sinr_e = abs(h1e'*WC)^2 / sigmaC2;
            ok3 = abs(sinr_e - Gamma1e) < 1e-4*Gamma1e;
            results(end+1) = struct('name', 'Theorem 3 (active regime): SINR met with equality', ...
                'passed', ok3, 'detail', sprintf('achieved=%.4f target=%.4f', sinr_e, Gamma1e));
        end
    else
        results(end+1) = struct('name', 'Theorem 3 setup', 'passed', false, 'detail', 'infeasible test point');
    end

    % -----------------------------------------------------------------
    % CHECK 5: compute_crb numerical sanity (monotonicity in power)
    % -----------------------------------------------------------------
    [a_vec, ~] = steering_vectors(0, Nt_test, 0.5);
    [b_vec, bdot_vec] = steering_vectors(0, 20, 0.5);
    crb_extra_pt = struct('a_vec',a_vec,'b_vec',b_vec,'bdot_vec',bdot_vec, ...
                           'alpha_true',1+0i,'L',30,'sigmaR2',1);
    RX_lowpower  = 0.1 * (a_vec*a_vec')/Nt_test;
    RX_highpower = 10  * (a_vec*a_vec')/Nt_test;
    crb_low  = compute_crb(RX_lowpower,  'point', crb_extra_pt);
    crb_high = compute_crb(RX_highpower, 'point', crb_extra_pt);
    ok = crb_high < crb_low;
    results(end+1) = struct('name', 'CRB(theta) decreases with more power toward target (monotonicity)', ...
        'passed', ok, 'detail', sprintf('CRB(low)=%.3e CRB(high)=%.3e', crb_low, crb_high));

    % -----------------------------------------------------------------
    % CHECK 6: rank1_extraction invariants (using a synthetic non-rank-1
    % PSD matrix, since we have no CVX solution available here)
    % -----------------------------------------------------------------
    rng(99);
    hk_test = (randn(Nt_test,1)+1i*randn(Nt_test,1))/sqrt(2);
    Vrand = randn(Nt_test,3)+1i*randn(Nt_test,3);
    Wk_hat_synthetic = Vrand*Vrand';   % rank-3 PSD matrix (not rank-1)
    [wk, Wk_tilde, gap] = rank1_extraction(Wk_hat_synthetic, hk_test);

    ok = norm(Wk_tilde - wk*wk','fro') < 1e-8;
    results(end+1) = struct('name', 'rank1_extraction: Wk_tilde == wk*wk'' exactly', 'passed', ok, ...
        'detail', sprintf('||Wk_tilde - wk*wk''||_F = %.3e', norm(Wk_tilde - wk*wk','fro')));

    sinr_num = real(hk_test'*wk);
    ok2 = abs(imag(hk_test'*wk)) < 1e-8 && sinr_num > 0;
    results(end+1) = struct('name', 'rank1_extraction: h''*wk is real and positive', 'passed', ok2, ...
        'detail', sprintf('h''*wk = %.4f + %.4fi', real(hk_test'*wk), imag(hk_test'*wk)));

    ok3 = gap > 0 && gap <= 1;   % synthetic matrix is genuinely rank-3, gap should be nonzero
    results(end+1) = struct('name', 'rank1_extraction: rank1_gap diagnostic is a valid ratio in (0,1]', ...
        'passed', ok3, 'detail', sprintf('rank1_gap = %.4f', gap));

    % -----------------------------------------------------------------
    % CHECK 7: compute_sinr point vs extended branch consistency
    % -----------------------------------------------------------------
    K_test = 3;
    Htest = generate_channel(K_test, Nt_test);
    Wtest = (randn(Nt_test,K_test)+1i*randn(Nt_test,K_test))/sqrt(2);
    gamma_point = compute_sinr(Htest, Wtest, 1.0, 'point');
    WAtest = zeros(Nt_test,Nt_test);   % zero auxiliary power -> extended should equal point
    gamma_ext_zero_WA = compute_sinr(Htest, Wtest, 1.0, 'extended', WAtest);
    ok = max(abs(gamma_point - gamma_ext_zero_WA)) < 1e-10;
    results(end+1) = struct('name', 'compute_sinr: extended with WA=0 matches point-target formula', ...
        'passed', ok, 'detail', sprintf('max|diff| = %.3e', max(abs(gamma_point - gamma_ext_zero_WA))));

    % -----------------------------------------------------------------
    % CHECK 8: compute_beampattern non-negativity and epsilon floor
    % -----------------------------------------------------------------
    angle_grid = deg2rad(-90:1:90);
    RXtest = (a_vec*a_vec')/Nt_test;
    bp = compute_beampattern(RXtest, angle_grid, 0.5);
    ok = all(isfinite(bp));
    results(end+1) = struct('name', 'compute_beampattern: all finite (no -Inf from log(0))', ...
        'passed', ok, 'detail', sprintf('any non-finite: %d', any(~isfinite(bp))));

    % -----------------------------------------------------------------
    % Summary
    % -----------------------------------------------------------------
    fprintf('\n%-70s %s\n', 'CHECK', 'RESULT');
    fprintf('%s\n', repmat('-',1,90));
    n_pass = 0;
    for i = 1:numel(results)
        status = 'FAIL';
        if results(i).passed
            status = 'PASS';
            n_pass = n_pass + 1;
        end
        fprintf('%-70s %s\n', results(i).name, status);
        if ~results(i).passed
            fprintf('    -> %s\n', results(i).detail);
        end
    end
    fprintf('%s\n', repmat('-',1,90));
    fprintf('TOTAL: %d/%d checks passed.\n', n_pass, numel(results));

    if n_pass < numel(results)
        error('validate_invariants:someChecksFailed', ...
            '%d of %d validation checks FAILED -- see detail above.', numel(results)-n_pass, numel(results));
    end
end
