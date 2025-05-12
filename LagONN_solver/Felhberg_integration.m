function [phaseX,phaseL,STOP,cost,Nflip] = Felhberg_integration(oldphaseX,oldphaseL,N,dt)

threshold_d=0.1/10; %in °/s
threshold_rad=threshold_d*pi/180;

STOP=0;
Nflip=0;
%Felhberg integration for LagONN
    % Euler step
    dphidt_Eu=LagONN_dynamics([oldphaseX',oldphaseL'],N);
     % computing cost
     cost=cost_func(oldphaseX');
     if cost>0.125
        if (dphidt_Eu(1)^2 <=threshold_rad^2) % first simple test for checking fixed point
            test=dphidt_Eu(1:N)*dphidt_Eu(1:N)';
            if (test<=N*threshold_rad^2) % reaching fixed point
                fprintf("Reached fixed point\n")
                STOP=1;
            end
        end
     else
         fprintf("Reached optimal solution\n")
         STOP=1;
     end
    newphaseX=oldphaseX+dt*dphidt_Eu(1:N);
    newphaseL=oldphaseL+dt*dphidt_Eu(N+1:end);
    % Heun integration
    dphidt_Heu=LagONN_dynamics([newphaseX',newphaseL'],N);
    % Heun integration at midpoint
    newphaseX=oldphaseX+dt*(dphidt_Eu(1:N)+dphidt_Heu(1:N))/4;
    newphaseL=oldphaseL+dt*(dphidt_Eu(N+1:end)+dphidt_Heu(N+1:end))/4;
    % Fehlberg integration
    dphidt_Fe=LagONN_dynamics([newphaseX',newphaseL'],N);
    % Heun predictor
    phaseX=oldphaseX+dt*(dphidt_Eu(1:N)+dphidt_Heu(1:N)+4*dphidt_Fe(1:N))/6; %simpson's rule
    phaseL=oldphaseL+dt*(dphidt_Eu(N+1:end)+dphidt_Heu(N+1:end)+4*dphidt_Fe(N+1:end))/6; %simpson's rule

    % checking phase flips
    for i=1:N
        if cos(oldphaseX(i))*cos(phaseX(i))<0
            Nflip=Nflip+1;
        end
    end
end