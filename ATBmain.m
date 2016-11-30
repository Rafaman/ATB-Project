%ATBmain

%% DEFINIZONI VARIABILI
%parametri personalizzabili
Nvittime=3;%(3)
%parametri funzionali
global FaseEsecuzione
FaseEsecuzione=1;
RegolatoreMainL=true; %valore booleano che regola loop principale
%% ESECUZIONE PROGRAMMA PRINCIPALE
ATBinitialize();
if FaseEsecuzione==1
    ATBpilot();
    ATBmove();
    if SegnalatoreArena
        FaseEsecuzione=2;%ATBnextstage()
    elseif SegnalatoreOstacolo
        ATBobstavoid();
        ATBmove();
    end
elseif FaseEsecuzione==2
    ATBarenascan();
    for LoopMod= 1:1:Nvittime
        ATBdetailedscan();
        ATBmove();
        while ApproccioCorretto==false
            ATBapprxtuner();
            ATBmove();
        end
        ATBobjgrabber();
    end
end