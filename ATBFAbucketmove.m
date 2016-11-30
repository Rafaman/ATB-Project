function ATBFAbucketmove(servoBucket,inputMov)
%clear;%***
%clc;%***
%ancora da testare
%% DEFINIZIONE VARIABILI
rappIngranaggi=36/18;
inclinazioneVite=2;%(spazio percorso vite in un giro in mm)
%% ESECUZIONE MOVIMENTO
durMovPrimario=inputMov/(inclinazioneVite*rappIngranaggi);
writePosition(servoBucket, 1);
cronometroMovPrimario=tic;
tempoEsecutivoPrimario=toc(cronometroMovPrimario);
while tempoEsecutivoPrimario < durMovPrimario
    tempoEsecutivoPrimario=toc(cronometroMovPrimario);
end
writePosition(servoBucket, 0);
end