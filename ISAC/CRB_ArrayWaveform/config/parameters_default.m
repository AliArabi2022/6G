function params = parameters_default()
%PARAMETERS_DEFAULT  Default scenario parameters shared across experiments.
%
% Values are taken directly from the paper where stated explicitly:
%   - Fig. 2 caption: theta = [0, 10, -10, 0] deg, phi = [90,80,70,60] deg,
%     gamma = 1_K, linear ULA aperture L=49 with Nt=Nr=15, planar UPA
%     aperture L=9 with Nt=Nr=30.
%   - Fig. 7 caption: linear array, aperture L=30, Nt=Nr=6, K=2, lambda=2.
%   - Fig. 3: Nt=Nr=18, aperture L=50.
%   - Fig. 4: Nt=Nr=30, aperture L=9.
%   - Fig. 5: Nt=Nr=50, aperture L=4 (cubic).
%   - Fig. 6: Nt=Nr=30, aperture L=9, K=3.
%
% ASSUMPTION (Phase 11): noise variance sigma2 is not stated numerically
% anywhere in the 5-page paper (the CRB/objective only needs sigma2 as a
% common positive scaling factor -- it cancels in the "coherent vs
% optimal" comparison of Fig. 2 and does not change the *arg min* array
% geometry of Algorithm 1, since g(Dt,Dr) is monotonic in sigma2 for
% fixed geometry-independent scaling). We set sigma2 = 1 throughout.
%
% Author: Ali ArabiBavil
% Date: 2026-07-07

    params.lambda  = 2;      % Fig. 7 caption: "lambda = 2"
    params.sigma2  = 1;      % ASSUMPTION: not specified in paper (see above)
    params.fType   = 'trace';% Sec. IV-B: "trace of the CRB"

    % Fig. 2 target scenario (up to 4 targets; select first K as needed)
    params.theta_deg_pool = [0, 10, -10, 0];
    params.phi_deg_pool   = [90, 80, 70, 60];

end
