function ATBFAsensmov(servoCorona,inputMov)
%clear;%***
%clc;%***
%% DEFINIZIONE VERIABILI
rappMovimenti=0.9;%rapporto fra movimento primario e secondario
rappIngranaggi=10/170;
rpsServoMassimi=1;
rpsCoronaMassimi=rpsServoMassimi*rappIngranaggi;
%% CALCOLO DURATA MOVIMENTI
deltaMovPrimario=inputMov*rappMovimenti; %variazione di angolo ottenuto nel primo movimento
durMovPrimario=deltaMovPrimario/rpsCoronaMassimi;
rpsCoronaSecondario=rpsCoronaMassimi*rappMovimenti;
deltaMovSecondario=inputMov-deltaMovPrimario; %variazione di angolo ottenuto nel secondo movimento
durMovSecondario=deltaMovSecondario/rpsCoronaSecondario;
%% ESECUZIONE MOVIMENTO PRIMARIO
writePosition(servoCorona, 1);
cronometroMovPrimario=tic;
tempoEsecutivoPrimario=toc(cronometroMovPrimario);
while tempoEsecutivoPrimario < durMovPrimario
    tempoEsecutivoPrimario=toc(cronometroMovPrimario);
end
%% ESECUZIONE MOVIMNETO SECONDARIO
writePosition(servoCorona, 0.5+0.5*rappMovimenti);
cronometroMovSecondario=tic;
tempoEsecutivoSecondario=toc(cronometroMovSecondario);
while tempoEsecutivoSecondario < durMovSecondario
    tempoEsecutivoSecondario=toc(cronometroMovSecondario);
end
writePosition(servoCorona, 0.5);
end