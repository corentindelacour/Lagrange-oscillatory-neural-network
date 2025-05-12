function dphidt=LagONN_dynamics(phi,N)
% dX_f and dL_f are symbolic functions defining the dynamics for a given
% 3SAT instance


dphi_X=(dX_func(phi(1:N),phi(N+1:end)));
dphi_L=(dL_func(phi(1:N),phi(N+1:end)));

dphidt=[dphi_X';dphi_L'];
