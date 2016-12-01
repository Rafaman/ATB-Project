
clc;
clear;
close;
%input:servoCorona
%NOTE: aggiungere eventualmente filtro rumore a misurazioni
%% DEFINIZIONE VARIABILI CONDIVISE
global disAttuale;
global dirAttuale;
posSensoriCorona=90;
altRicercaObj=20; %altezza sensori dal terreno in posizione di ricerca ogetti in mm +++definisci+++
altRicercaZR=60+0; %altezza sensori zona di recupero (60 mm + correzione angolo emissione)+++definisci+++
altRaccolta=10; %altezza riferita ai sensori raccolta ogetti in mm +++definisci+++
posSensoriCoronaMin=0;
posSensoriCoronaMax=90+45;
precAnalisiObj=0.5; %rapporto fra 1 grado e numero di misurazioniObj ricerca ogetti +++definisci+++
precAnalisiZR=1; %rapporto fra 1 grado e numero di misurazioniObj ricerca zona recupero +++definisci+++
disApproccio= 10; %distanza alla quale inizia la fase di approccio +++definisci+++
diffAngScanner= 22; %differenza in ° fra direzione andamento robot a direzione centrale raggio sensore
%% ALLINEAMENTO LINEA ENTRATA ARENA

%% ESECUZIONE ANALISI 1
%si porta il sensore a posizione zero
%ATBFAsensmov(servoCorona,posSensoriCoronaMin-posSensoriCorona);+++decommentare+++
%esecuzione misurazione1
indMisurazioni=0;
misurazioniObj=zeros(1,posSensoriCoronaMax/precAnalisiObj);
for posSensoriCorona = posSensoriCoronaMin:precAnalisiObj:posSensoriCoronaMax
    indMisurazioni=+1;
    %ATBFAsensmov(servoCorona,precAnalisiArena);+++decommentare+++
    %misurazioniObj(indMisurazioni) = ATBFlettSensori();+++decommentare+++
end
%creazione parametri debug
misurazioniObj(:)=0; %***
debugIndRandA=round(rand*posSensoriCoronaMax); %***
debugIndRandB=round(rand*posSensoriCoronaMax); %***
debugValRandA=rand*90; %***
debugValRandB=rand*90; %***
misurazioniObj(debugIndRandA:round(debugIndRandA+rand*6))=debugValRandA; %***
misurazioniObj(debugIndRandB:round(debugIndRandB+rand*6))=debugValRandB; %***
plot(misurazioniObj);hold on; %***
%si riporta i sensori al centro
%ATBFAsensmov(servoCorona,-45);+++decommentare+++
%esecuzione analisi misurazione1
ogettiMisurazioni=bwconncomp(misurazioniObj);%+++rinominare+++
numOgetti=ogettiMisurazioni.NumObjects;
disObj=zeros(1,numOgetti);
indObjCell=ogettiMisurazioni.PixelIdxList;
for loopMod = 1:numOgetti
    [lunghezza,~] = size(cell2mat(indObjCell(loopMod)));
    indObj(1:lunghezza,loopMod) = cell2mat(indObjCell(loopMod)); %#ok<SAGROW>
    disObj(loopMod) = mean(misurazioniObj(indObj(1:lunghezza,loopMod)));
end
dirObj=mean(indObj)*precAnalisiObj;
%elaborazione direzione e distanza secondo movimento
if(disObj(2) ~= 0)
disObjACC = disObj(1)^2+disObj(2)^2-2*disObj(1)*disObj(2)*cos(dirObj(1)-dirObj(2));
dirObjACC = 270 - acosd((disObjACC^2+disObj(1)^2-disObj(2)^2)/2*disObjACC*disObj(1));
disObj(2) = disObjACC;
dirObj(2) = dirObjACC;
end
%% ESECUZIONE RICERCA ZONA RECUPERO 1
% si portano i sensori ad altezza zona di recupero (60 mm + correzione angolo emissione)
%ATBFAbucketmove(servoBucket,altRicercaZR-altRicercaObj);+++decommentare+++
while true
%si porta il sensore a posizione zero
%ATBFAsensmov(servoCorona,posSensoriCoronaMin-posSensoriCorona);+++decommentare+++
%esecuzione misurazione zona recupero
misurazioniZR=zeros(1,posSensoriCoronaMax/precAnalisiZR);
indMisurazioni=0;
    for posSensoriCorona = posSensoriCoronaMin:precAnalisiObj:posSensoriCoronaMax
        indMisurazioni=+1;
        %ATBFAsensmov(servoCorona,precAnalisiArena);+++decommentare+++
        %misurazioniZR(indMisurazioni) = ATBFlettSensori();+++decommentare+++
    end
%creazione parametri debug 
misurazioniZR(:)=0; %***
debugIndRandA=round(rand*posSensoriCoronaMax); %***
debugValRandA=rand*100; %***
misurazioniZR(debugIndRandA:round(debugIndRandA+rand*12))=debugValRandA; %***
plot(misurazioniZR); %***
%si riporta i sensori al centro
%ATBFAsensmov(servoCorona,-45);+++decommentare+++
MisurazioniZR = bwconncomp(misurazioniZR);%+++rinominare+++
numZR=MisurazioniZR.NumObjects;
indZRCell=MisurazioniZR.PixelIdxList;
    if(numZR == 1||0)
        [lunghezza,~] = size(cell2mat(indZRCell));
        indZR(1:lunghezza) = cell2mat(indZRCell);
        disZR = mean(misurazioniZR(indZR(1:lunghezza)));
        dirZR = mean(indZR)*precAnalisiZR;
    break;
    end
end
% si riportano i sensori ad altezza ogetti
%ATBFAbucketmove(servoBucket,altRicercaObj-altRicercaZR);+++decommentare+++
%% ENTRATA ARENA
modoEA=1;angoloEA=0;distanzaEA=20;%distanza che deve compiere il robot
%per entrare completamente nell'arena (da definire, in cm) +++definisci+++
%ATBmove(modoEA,angoloEA,distanzaEA,servoADX,servoASX,servoPDX,servoPSX);+++decommentare+++
disAttuale=0
dirAttuale=90;
%% RACCOLTA OGETTI 1
modoRO=zeros(1,numOgetti);
angoloRO=zeros(1,numOgetti);
distanzaRO=zeros(1,numOgetti);
for OgettoCorrente = 1:numOgetti
    %raggiungere ogetto
    if(dirObj(OgettoCorrente)) <= 90
        modoRO(OgettoCorrente)=2;
        angoloRO(OgettoCorrente)=90-dirObj(OgettoCorrente);
    else
        modoRO(OgettoCorrente)=1;
        angoloRO(OgettoCorrente)=dirObj(OgettoCorrente)-90;
    end
    distanzaRO(OgettoCorrente) = disObj(OgettoCorrente) - disApproccio;
    %ATBmove(modoRO(OgettoCorrente),angoloRO(OgettoCorrente),distanzaRO(OgettoCorrente),servoADX,servoASX,servoPDX,servoPSX);+++decommentare+++
    if(OgettoCorrente==1)
        disAttuale = disObj(OgettoCorrente);
        dirAttuale = dirObj(OgettoCorrente);
    else
        disAttuale=sqrt(disObj(OgettoCorrente)^2+disObj(OgettoCorrente-1)^2-disObj(OgettoCorrente-1)*disObj(OgettoCorrente)*cos(180-angoloRO(OgettoCorrente)));
        dirAttuale=asind(disObj(OgettoCorrente)*sin(180-angoloRO(OgettoCorrente))/disAttuale)-90+angoloRO(OgettoCorrente-1);
        %per le formule vedi reference scritta 2A
    end
    %regolare approccio
    %[disAprxY,disAprxX]=ATBFAlocateObj(cam);+++decommentare+++
    %disAprx=sqrt(disAprxY^2+disAprxX^2);+++decommentare+++
    %angAprx=acosd(disAprxY/disAprx);+++decommentare+++
    %if(disAprxX>0) modoAprx = 2; %#ok<SEPEX>+++decommentare+++
    %else modoAprx = 1;           %#ok<SEPEX>+++decommentare+++
    %end+++decommentare+++
    %ATBmove(modoAprx,angAprx,disAprx,servoADX,servoASX,servoPDX,servoPSX);+++decommentare+++
    %raccolta ogetto
    %ATBFAbucketmove(servoBucket,altRaccolta-altRicercaObj);+++decommentare+++
    %ATBFAbucketTurn(servoRotore);+++decommentare+++
    %ATBFAbucketmove(servoBucket,altRicercaObj-altRaccolta);+++decommentare+++
end
%% ESECUZIONE ANALISI 2
%elaborazione movimento posizionamento
distanzaA2 = 0;
angoloA2 = 90 - dirObj(2) + diffAngScanner; %viene aggiunto 22.5 per porre il sensore nel mezzo del suo raggio di detezione
if(angoloA2) > 0
        modoA2=2;
    else
        modoA2=1;
        angoloA2 = abs(angoloA2);
end
%posizionamento analisi 2
%ATBmove(modoA2,angoloA2,distanzaA2,servoADX,servoASX,servoPDX,servoPSX);+++decommentare+++
%esecuzione analisi
indMisurazioni=0;
misurazioniObj=zeros(1,posSensoriCoronaMax/precAnalisiObj);
for posSensoriCorona = posSensoriCoronaMin:precAnalisiObj:posSensoriCoronaMax
    indMisurazioni=+1;
    %ATBFAsensmov(servoCorona,precAnalisiArena);+++decommentare+++
    %misurazioniObj(indMisurazioni) = ATBFlettSensori();+++decommentare+++
end
%creazione parametri debug
misurazioniObj(:)=0; %***
debugIndRandA=round(rand*posSensoriCoronaMax); %***
debugIndRandB=round(rand*posSensoriCoronaMax); %***
debugValRandA=rand*90; %***
debugValRandB=rand*90; %***
misurazioniObj(debugIndRandA:round(debugIndRandA+rand*6))=debugValRandA; %***
misurazioniObj(debugIndRandB:round(debugIndRandB+rand*6))=debugValRandB; %***
plot(misurazioniObj);hold on; %***
%si riporta i sensori al centro
%ATBFAsensmov(servoCorona,-45);+++decommentare+++
%esecuzione analisi misurazione1
ogettiMisurazioni=bwconncomp(misurazioniObj);%+++rinominare+++
numOgetti=ogettiMisurazioni.NumObjects;
disObj=zeros(1,numOgetti);
indObjCell=ogettiMisurazioni.PixelIdxList;
for loopMod = 1:numOgetti
    [lunghezza,~] = size(cell2mat(indObjCell(loopMod)));
    indObj(1:lunghezza,loopMod) = cell2mat(indObjCell(loopMod));
    disObj(loopMod) = mean(misurazioniObj(indObj(1:lunghezza,loopMod)));
end
dirObj=mean(indObj)*precAnalisiObj;
%% ESECUZIONE RICERCA ZONA RECUPERO 2
if(numZR==0)
    % si portano i sensori ad altezza zona di recupero (60 mm + correzione angolo emissione)
    %ATBFAbucketmove(servoBucket,altRicercaZR-altRicercaObj);+++decommentare+++
    while true
    %si porta il sensore a posizione zero
    %ATBFAsensmov(servoCorona,posSensoriCoronaMin-posSensoriCorona);+++decommentare+++
    %esecuzione misurazione zona recupero
    misurazioniZR=zeros(1,posSensoriCoronaMax/precAnalisiZR);
    indMisurazioni=0;
        for posSensoriCorona = posSensoriCoronaMin:precAnalisiObj:posSensoriCoronaMax
            indMisurazioni=+1;
            %ATBFAsensmov(servoCorona,precAnalisiArena);+++decommentare+++
            %misurazioniZR(indMisurazioni) = ATBFlettSensori();+++decommentare+++
        end
    %creazione parametri debug 
    misurazioniZR(:)=0; %***
    debugIndRandA=round(rand*posSensoriCoronaMax); %***
    debugValRandA=rand*100; %***
    misurazioniZR(debugIndRandA:round(debugIndRandA+rand*12))=debugValRandA; %***
    plot(misurazioniZR); %***
    %si riporta i sensori al centro
    %ATBFAsensmov(servoCorona,-45);+++decommentare+++
    MisurazioniZR = bwconncomp(misurazioniZR);%+++rinominare+++
    numZR=MisurazioniZR.NumObjects;
    indZRCell=MisurazioniZR.PixelIdxList;
        if(numZR == 1)
            [lunghezza,~] = size(cell2mat(indZRCell));
            indZR(1:lunghezza) = cell2mat(indZRCell);
            disZR = mean(misurazioniZR(indZR(1:lunghezza)));
            dirZR = mean(indZR)*precAnalisiZR;
            %generazione variabile posizione relativa
            
        break;
        end
    end
    % si riportano i sensori ad altezza ogetti
    %ATBFAbucketmove(servoBucket,altRicercaObj-altRicercaZR);+++decommentare+++
end
%% RACCOLTA OGETTI 2
for OgettoCorrente = 1:numOgetti
    %raggiungere ogetto
    if(dirObj(OgettoCorrente)) <= 90
        modoRO=2;
        angoloRO=90-dirObj(OgettoCorrente);
    else
        modoRO=1;
        angoloRO=dirObj(OgettoCorrente)-90;
    end
    distanzaRO = disObj - disApproccio;
    %ATBmove(modoRO,angoloRO,distanzaRO,servoADX,servoASX,servoPDX,servoPSX);+++decommentare+++
    %regolare approccio
    %[disAprxY,disAprxX]=ATBFAlocateObj(cam);+++decommentare+++
    %disAprx=sqrt(disAprxY^2+disAprxX^2);+++decommentare+++
    %angAprx=acosd(disAprxY/disAprx);+++decommentare+++
    %if(disAprxX>0) modoAprx = 2; %#ok<SEPEX>+++decommentare+++
    %else modoAprx = 1;           %#ok<SEPEX>+++decommentare+++
    %end+++decommentare+++
    %ATBmove(modoAprx,angAprx,disAprx,servoADX,servoASX,servoPDX,servoPSX);+++decommentare+++
    %raccolta ogetto
    %ATBFAbucketmove(servoBucket,altRaccolta-altRicercaObj);+++decommentare+++
    %ATBFAbucketTurn(servoRotore);+++decommentare+++
    %ATBFAbucketmove(servoBucket,altRicercaObj-altRaccolta);+++decommentare+++
end
%% DEPOSITO
%/////bisogna stabilire posizione del robot
%/////bisogna stabilire posizione della zona di recupero
%/////generazione dati movimento
%/////esecuzione movimento
%/////innalzamento cestello
%/////approccio zona di recupero
%/////deposito
%/////display segnale fine programma
%% DEBUG PLOT
hold off;