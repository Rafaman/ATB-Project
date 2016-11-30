function ATBFAbucketTurn(servoRotore)
durMov=1*1/4; %gli rps sono =1 e il rotore deve spostarsi di 1/4
writePosition(servoRotore, 1);
cronometroMovPrimario=tic;
tempoEsecutivoPrimario=toc(cronometroMovPrimario);
while tempoEsecutivoPrimario < durMov
    tempoEsecutivoPrimario=toc(cronometroMovPrimario);
end
writePosition(servoRotore, 0);
end