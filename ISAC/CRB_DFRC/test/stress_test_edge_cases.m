function stress_test_edge_cases()
%STRESS_TEST_EDGE_CASES Phase 12 adversarial edge-case / boundary sweep.
%
%   Deliberately probes degenerate, boundary, and malformed inputs
%   across the CVX-free modules to surface dimension mismatches,
%   numerical instability, and unhandled edge cases that normal-
%   operating-point testing (Phase 11) would not exercise.
%
%   Each check prints PASS/FAIL/(expected)ERROR. Unlike
%   validate_invariants.m (which asserts CORRECT VALUES), this suite
%   mostly asserts GRACEFUL BEHAVIOR: either a sensible numeric result,
%   or a clean, attributable error/warning -- never a silent NaN,
%   crash-with-cryptic-message, or wrong-size output.
%
%
%   Author: Ali Arabi Bavil
%   Date:   2026

    proj_root = fileparts(fileparts(mfilename('fullpath')));
    addpath(genpath(proj_root));

    n_pass = 0; n_total = 0;
    fprintf('=== Phase 12 Edge-Case Stress Test ===\n\n');

    % -----------------------------------------------------------------
    % EDGE 1: Nt=1 (degenerate single-antenna "array")
    % -----------------------------------------------------------------
    n_total = n_total + 1;
    try
        [a1, adot1] = steering_vectors(deg2rad(10), 1, 0.5);
        ok = isequal(size(a1),[1 1]) && a1==1 && adot1==0;
        report('Nt=1 steering vector degenerates correctly (a=1, adot=0)', ok);
        if ok, n_pass = n_pass+1; end
    catch ME
        report_error('Nt=1 steering vector', ME);
    end

    % -----------------------------------------------------------------
    % EDGE 2: extended_singleuser with Nt=1 (Nt-1=0 -> empty WA)
    % -----------------------------------------------------------------
    n_total = n_total + 1;
    try
        h1 = 1+0.5i;
        [WC, WA, diagE] = extended_singleuser(h1, 0.1, 1, 1, 1);
        ok = isequal(size(WA), [1 0]) && diagE.feasible;
        report('extended_singleuser Nt=1: WA is 1x0 (empty), no crash', ok);
        if ok, n_pass = n_pass+1; end
    catch ME
        report_error('extended_singleuser Nt=1', ME);
    end

    % -----------------------------------------------------------------
    % EDGE 3: pointtarget_singleuser with a_vec EXACTLY parallel to h1
    % (degenerate Gram-Schmidt -- Phase 3 Sec.3.5 flagged numerical issue)
    % -----------------------------------------------------------------
    n_total = n_total + 1;
    try
        Nt = 8;
        [a_vec, ~] = steering_vectors(deg2rad(20), Nt, 0.5);
        h1_parallel = 3.7 * a_vec;   % EXACTLY parallel, not just close
        [w1, diagP] = pointtarget_singleuser(a_vec, h1_parallel, 2, 1, 1);
        ok = diagP.feasible && all(isfinite(w1)) && ~any(isnan(w1));
        report('pointtarget_singleuser: a_vec exactly parallel to h1 (degenerate Gram-Schmidt)', ok);
        if ok, n_pass = n_pass+1; end
    catch ME
        report_error('pointtarget_singleuser degenerate parallel case', ME);
    end

    % -----------------------------------------------------------------
    % EDGE 4: compute_crb 'extended' with a DELIBERATELY singular RX
    % (should trigger the pinv fallback + warning, not crash or return
    % a silently-wrong finite number)
    % -----------------------------------------------------------------
    n_total = n_total + 1;
    try
        Nt = 8;
        v = randn(Nt,1)+1i*randn(Nt,1);
        RX_singular = v*v';   % rank-1, deliberately singular for Nt>1
        crb_extra = struct('Nr',10,'L',30,'sigmaR2',1);
        w = warning('off','all');
        CRB_val = compute_crb(RX_singular, 'extended', crb_extra);
        warning(w);
        ok = isfinite(CRB_val) && CRB_val > 0;
        report('compute_crb extended: singular RX handled via pinv fallback (finite, positive result)', ok);
        if ok, n_pass = n_pass+1; end
    catch ME
        report_error('compute_crb singular RX', ME);
    end

    % -----------------------------------------------------------------
    % EDGE 5: compute_crb 'point' with RX that places ZERO power on target
    % (should return Inf with a warning, not crash or return NaN)
    % -----------------------------------------------------------------
    n_total = n_total + 1;
    try
        Nt = 8;
        [a_vec, ~] = steering_vectors(0, Nt, 0.5);
        [b_vec, bdot_vec] = steering_vectors(0, 10, 0.5);
        % Build RX entirely orthogonal to a_vec (zero power toward target)
        null_basis = null(a_vec');
        v = null_basis(:,1);
        RX_orthogonal = v*v';
        crb_extra = struct('a_vec',a_vec,'b_vec',b_vec,'bdot_vec',bdot_vec,'alpha_true',1,'L',30,'sigmaR2',1);
        w = warning('off','all');
        CRB_val = compute_crb(RX_orthogonal, 'point', crb_extra);
        warning(w);
        ok = isinf(CRB_val) && CRB_val > 0;
        report('compute_crb point: zero power toward target returns +Inf (not NaN/crash)', ok);
        if ok, n_pass = n_pass+1; end
    catch ME
        report_error('compute_crb zero-power-toward-target', ME);
    end

    % -----------------------------------------------------------------
    % EDGE 6: aggregate_mc with a method that is ENTIRELY infeasible
    % (zero valid trials at this sweep point)
    % -----------------------------------------------------------------
    n_total = n_total + 1;
    try
        trial_results = randn(20, 2, 2);
        feas = true(20,2);
        feas(:,2) = false;   % method 2 entirely infeasible
        w = warning('off','all');
        [m, s, ff] = aggregate_mc(trial_results, feas);
        warning(w);
        ok = all(isfinite(m(:,1))) && all(isnan(m(:,2))) && ff(2)==0 && ff(1)==1;
        report('aggregate_mc: fully-infeasible method returns NaN (not crash), other method unaffected', ok);
        if ok, n_pass = n_pass+1; end
    catch ME
        report_error('aggregate_mc fully-infeasible column', ME);
    end

    % -----------------------------------------------------------------
    % EDGE 7: aggregate_mc with EXACTLY ONE feasible trial (the
    % squeeze() dimension-collapse pitfall flagged in Phase 8 Sec.8.15)
    % -----------------------------------------------------------------
    n_total = n_total + 1;
    try
        trial_results = randn(20, 3, 1);   % 3 metrics, 1 method
        feas = false(20,1);
        feas(5) = true;   % exactly one feasible trial
        [m, s, ff] = aggregate_mc(trial_results, feas);
        ok = isequal(size(m), [3 1]) && all(isfinite(m)) && ff==1/20;
        report('aggregate_mc: exactly one feasible trial does not corrupt output orientation', ok);
        if ok, n_pass = n_pass+1; end
    catch ME
        report_error('aggregate_mc single-feasible-trial', ME);
    end

    % -----------------------------------------------------------------
    % EDGE 8: rank1_extraction with hk = 0 (should error cleanly, not
    % silently divide by zero into NaN/Inf)
    % -----------------------------------------------------------------
    n_total = n_total + 1;
    try
        Nt = 6;
        Wk_hat = eye(Nt);
        hk_zero = zeros(Nt,1);
        threw = false;
        try
            rank1_extraction(Wk_hat, hk_zero);
        catch
            threw = true;
        end
        report('rank1_extraction: hk=0 throws a clean error (not silent NaN)', threw);
        if threw, n_pass = n_pass+1; end
    catch ME
        report_error('rank1_extraction hk=0 outer', ME);
    end

    % -----------------------------------------------------------------
    % EDGE 9: compute_sinr with K=1 (other_idx empty -- Phase 8 Sec.8.5
    % claimed this works without a special case; verify it actually does)
    % -----------------------------------------------------------------
    n_total = n_total + 1;
    try
        H1 = (randn(1,8)+1i*randn(1,8))/sqrt(2);
        W1 = (randn(8,1)+1i*randn(8,1))/sqrt(2);
        gamma1 = compute_sinr(H1, W1, 1.0, 'point');
        expected = abs(H1*W1)^2 / 1.0;
        ok = isequal(size(gamma1),[1 1]) && abs(gamma1-expected) < 1e-10;
        report('compute_sinr K=1: no special-case needed, matches direct formula', ok);
        if ok, n_pass = n_pass+1; end
    catch ME
        report_error('compute_sinr K=1', ME);
    end

    % -----------------------------------------------------------------
    % EDGE 10: steering_vectors_grid with a single-point grid (Ngrid=1)
    % -----------------------------------------------------------------
    n_total = n_total + 1;
    try
        Ag = steering_vectors_grid(0, 8, 0.5);
        ok = isequal(size(Ag),[8 1]);
        report('steering_vectors_grid: single-angle grid returns correct Nt x 1 shape', ok);
        if ok, n_pass = n_pass+1; end
    catch ME
        report_error('steering_vectors_grid single-point', ME);
    end

    % -----------------------------------------------------------------
    % EDGE 11: dBm2Watt vectorized input (array, not scalar)
    % -----------------------------------------------------------------
    n_total = n_total + 1;
    try
        w_arr = dBm2Watt([0 10 30]);
        ok = numel(w_arr)==3 && abs(w_arr(3)-1.0) < 1e-9;
        report('dBm2Watt: vectorized input works, 30dBm -> 1W exactly', ok);
        if ok, n_pass = n_pass+1; end
    catch ME
        report_error('dBm2Watt vectorized', ME);
    end

    % -----------------------------------------------------------------
    % EDGE 12: results_dir() consistency check (Phase 12's own bug fix)
    % -----------------------------------------------------------------
    n_total = n_total + 1;
    try
        old_pwd = pwd;
        cd(tempdir);   % simulate running from an unrelated working directory
        rdir1 = results_dir();
        cd(old_pwd);
        rdir2 = results_dir();
        ok = strcmp(rdir1, rdir2);
        report('results_dir(): path is IDENTICAL regardless of caller''s pwd (Phase 12 bug fix verified)', ok);
        if ok, n_pass = n_pass+1; end
    catch ME
        cd(old_pwd);
        report_error('results_dir() cwd-independence', ME);
    end

    fprintf('\nTOTAL: %d/%d edge-case checks passed.\n', n_pass, n_total);
    if n_pass < n_total
        error('stress_test_edge_cases:someChecksFailed', '%d edge-case checks failed.', n_total-n_pass);
    end
end

function report(name, ok)
    status = 'FAIL';
    if ok, status = 'PASS'; end
    fprintf('%-85s %s\n', name, status);
end

function report_error(name, ME)
    fprintf('%-85s ERROR\n', name);
    fprintf('    -> %s\n', ME.message);
end
