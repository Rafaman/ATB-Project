
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
altDeposito= 70;%altezza riferita ai sensori deposito ogetti in mm +++definisci+++
posSensoriCoronaMin=0;
posSensoriCoronaMax=90+45;
precAnalisiObj=0.5; %rapporto fra 1 grado e numero di misurazioniObj ricerca ogetti +++definisci+++
precAnalisiZR=1; %rapporto fra 1 grado e numero di misurazioniObj ricerca zona recupero +++definisci+++
disApproccio= 10; %distanza alla quale inizia la fase di approccio +++definisci+++
diffAngScanner= 22; %differenza in � fra direzione andamento robot a direzione centrale raggio sensore
%% ALLINEAMENTO LINEA ENTRATA ARENA

%% ESECUZIONE ANALISI 1
%si porta il sensore a posizione zero
%ATBFAsensmov(servoCorona,posSensoriCoronaMin-posSensoriCorona);+++decommentare+++
%esecuzione misurazione1
indMisurazioni=0;
misurazioniObj1=zeros(1,posSensoriCoronaMax/precAnalisiObj);
for posSensoriCorona = posSensoriCoronaMin:precAnalisiObj:posSensoriCoronaMax
    indMisurazioni=+1;
    %ATBFAsensmov(servoCorona,precAnalisiArena);+++decommentare+++
    %misurazioniObj1(indMisurazioni) = ATBFlettSensori();+++decommentare+++
end
%creazione parametri debug
misurazioniObj1(:)=0; %***
debugIndRandA=round(rand*posSensoriCoronaMax); %***
debugIndRandB=round(rand*posSensoriCoronaMax); %***
debugValRandA=rand*90; %***
debugValRandB=rand*90; %***
misurazioniObj1(debugIndRandA:round(debugIndRandA+rand*6))=debugValRandA; %***
misurazioniObj1(debugIndRandB:round(debugIndRandB+rand*6))=debugValRandB; %***
plot(misurazioniObj1);hold on; %***
%si riporta i sensori al centro
%ATBFAsensmov(servoCorona,-45);+++decommentare+++
%esecuzione analisi misurazione1
ogettiMisurazioni1=bwconncomp(misurazioniObj1);%+++rinominare+++
numOgetti1=ogettiMisurazioni1.NumObjects;
disObj1=zeros(1,numOgetti1);
indObjCell1=ogettiMisurazioni1.PixelIdxList;
for loopMod = 1:numOgetti1
    [lunghezza,~] = size(cell2mat(indObjCell1(loopMod)));
    indObj1(1:lunghezza,loopMod) = cell2mat(indObjCell1(loopMod)); %#ok<SAGROW>
    disObj1(loopMod) = mean(misurazioniObj1(indObj1(1:lunghezza,loopMod)));
end
dirObj1=mean(indObj1)*precAnalisiObj;
%elaborazione direzione e distanza secondo movimento
if(disObj1(2) ~= 0)
disObjACC = disObj1(1)^2+disObj1(2)^2-2*disObj1(1)*disObj1(2)*cos(dirObj1(1)-dirObj1(2));
dirObjACC = 270 - acosd((disObjACC^2+disObj1(1)^2-disObj1(2)^2)/2*disObjACC*disObj1(1));
disObj1(2) = disObjACC;
dirObj1(2) = dirObjACC;
end
%% ESECUZIONE RICERCA ZONA RECUPERO 1
% si portano i sensori ad altezza zona di recupero (60 mm + correzione angolo emissione)
%ATBFAbucketmove(servoBucket,altRicercaZR-altRicercaObj);+++decommentare+++
%si imposta cantro sistema di riferimento
disAttuale=0;
dirAttuale=90;
%si procede con l'analisi
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
MisurazioniZR1 = bwconncomp(misurazioniZR);%+++rinominare+++
numZR1=MisurazioniZR1.NumObjects;
indZRCell=MisurazioniZR1.PixelIdxList;
    if(numZR1 == 1||0)
        [lunghezza1,~] = size(cell2mat(indZRCell));
        indZR1(1:lunghezza1) = cell2mat(indZRCell);
        disZR1 = mean(misurazioniZR(indZR1(1:lunghezza1)));
        dirZR1 = mean(indZR1)*precAnalisiZR;
        %calcolo posizione assoluta ZR
        if(numZR1 == 1)
            disAssZR = sqrt(disZR1^2+disAttuale^2-disZR1*disAttuale*cos(180-dirZR1));
            dirAssZR = asind(disZR1*sin(180-dirZR1)/disAssZR)-90+disZR1;
        end
    break;
    end
end
% si riportano i sensori ad altezza ogetti
%ATBFAbucketmove(servoBucket,altRicercaObj-altRicercaZR);+++decommentare+++
%% ENTRATA ARENA
modoEA=1;angoloEA=0;distanzaEA=20;%distanza che deve compiere il robot
%per entrare completamente nell'arena (da definire, in cm) +++definisci+++
%ATBmove(modoEA,angoloEA,distanzaEA,servoADX,servoASX,servoPDX,servoPSX);+++decommentare+++
%% RACCOLTA OGETTI 1
modoRO=zeros(1,numOgetti1);
angoloRO=zeros(1,numOgetti1);
distanzaRO=zeros(1,numOgetti1);
for OgettoCorrente = 1:numOgetti1
    %raggiungere ogetto
    if(dirObj1(OgettoCorrente)) <= 90
        modoRO(OgettoCorrente)=2;
        angoloRO(OgettoCorrente)=90-dirObj1(OgettoCorrente);
    else
        modoRO(OgettoCorrente)=1;
        angoloRO(OgettoCorrente)=dirObj1(OgettoCorrente)-90;
    end
    distanzaRO(OgettoCorrente) = disObj1(OgettoCorrente) - disApproccio;
    %ATBmove(modoRO(OgettoCorrente),angoloRO(OgettoCorrente),distanzaRO(OgettoCorrente),servoADX,servoASX,servoPDX,servoPSX);+++decommentare+++
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
angoloA2 = 90 - dirObj1(2) + diffAngScanner; %viene aggiunto 22.5 per porre il sensore nel mezzo del suo raggio di detezione
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
misurazioniObj2=zeros(1,posSensoriCoronaMax/precAnalisiObj);
for posSensoriCorona = posSensoriCoronaMin:precAnalisiObj:posSensoriCoronaMax
    indMisurazioni=+1;
    %ATBFAsensmov(servoCorona,precAnalisiArena);+++decommentare+++
    %misurazioniObj1(indMisurazioni) = ATBFlettSensori();+++decommentare+++
end
%creazione parametri debug
misurazioniObj2(:)=0; %***
debugIndRandA=round(rand*posSensoriCoronaMax); %***
debugIndRandB=round(rand*posSensoriCoronaMax); %***
debugValRandA=rand*90; %***
debugValRandB=rand*90; %***
misurazioniObj2(debugIndRandA:round(debugIndRandA+rand*6))=debugValRandA; %***
misurazioniObj2(debugIndRandB:round(debugIndRandB+rand*6))=debugValRandB; %***
plot(misurazioniObj2);hold on; %***
%si riporta i sensori al centro
%ATBFAsensmov(servoCorona,-45);+++decommentare+++
%esecuzione analisi misurazione1
ogettiMisurazioni2=bwconncomp(misurazioniObj2);%+++rinominare+++
numOgetti2=ogettiMisurazioni2.NumObjects;
disObj2=zeros(1,numOgetti2);
indObjCell2=ogettiMisurazioni2.PixelIdxList;
for loopMod = 1:numOgetti2
    [lunghezza,~] = size(cell2mat(indObjCell2(loopMod)));
    indObj2(1:lunghezza,loopMod) = cell2mat(indObjCell2(loopMod)); %#ok<SAGROW>
    disObj2(loopMod) = mean(misurazioniObj2(indObj2(1:lunghezza,loopMod)));
end
dirObj2=mean(indObj2)*precAnalisiObj;
%% ESECUZIONE RICERCA ZONA RECUPERO 2
if(numZR1==0)
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
    MisurazioniZR2 = bwconncomp(misurazioniZR);%+++rinominare+++
    numZR2=MisurazioniZR2.NumObjects;
    indZRCell=MisurazioniZR2.PixelIdxList;
        if(numZR2 == 1)
            [lunghezza2,~] = size(cell2mat(indZRCell));
            indZR2(1:lunghezza2) = cell2mat(indZRCell);
            disZR2 = mean(misurazioniZR(indZR2(1:lunghezza2)));
            dirZR2 = mean(indZR2)*precAnalisiZR;
            %calcolo posizione assoluta
            disAssZR = sqrt(disZR2^2+disAttuale^2-disZR2*disAttuale*cos(180-dirZR2));
            dirAssZR = asind(disZR2*sin(180-dirZR2)/disAssZR)-90+disZR2;
        break;
        end
    end
    % si riportano i sensori ad altezza ogetti
    %ATBFAbucketmove(servoBucket,altRicercaObj-altRicercaZR);+++decommentare+++
end
%% RACCOLTA OGETTI 2
for OgettoCorrente = 1:numOgetti2
    %raggiungere ogetto
    if(dirObj2(OgettoCorrente)) <= 90
        modoRO=2;
        angoloRO=90-dirObj2(OgettoCorrente);
    else
        modoRO=1;
        angoloRO=dirObj2(OgettoCorrente)-90;
    end
    distanzaRO = disObj2 - disApproccio;
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
%generazione dati movimento
disMovZR = sqrt(disAssZR^2+disAttuale^2-2*dirAssZR*disAttuale*cos(dirAttuale-dirAssZR));
dirMoveZR = 180 - acosd((disMovZR^2+disAttuale^2-disAssZR^2)/(2*disMovZR*disAttuale));
if(dirAssZR>dirAttuale)
    modoZR = 1; %il robot svolta a destra
else
    modoZR = 2; %il robot svolta a sinistra
end
distanzaZR = disMovZR - disApproccio;
%innalzamento cestello
%ATBFAbucketmove(servoBucket,altDeposito-altRicercaObj);+++decommentare+++
%esecuzione movimento
%ATBmove(modoZR,dirMoveZR,distanzaZR,servoADX,servoASX,servoPDX,servoPSX);+++decommentare+++
%approccio zona di recupero
%per  il momento l'approccio � eseguito come un semplice avvicinamento
%ATBmove(1,0,disApproccio,servoADX,servoASX,servoPDX,servoPSX);+++decommentare+++
%deposito
for depMod =1:4
    %ATBFAbucketTurn(servoRotore);+++decommentare+++
end
%display segnale fine programma(da definire)
%inserisci gui
disp('fine');
%% DEBUG PLOT
hold off;