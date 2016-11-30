
function [OutModi,OutAngoli,OutDistanza]=ATBpilota(cam)
clc;%eliminare
clear;%eliminare
%---------DEFINIZIONE VARIABILI--------------------------------------------
global RisoluzioneGlobaleX;%risoluzione globale immagini x
global RisoluzioneGlobaleY;%risoluzione globale immagini y
RisoluzioneGlobaleX=640;%*** aggiungi al setup hardware
RisoluzioneGlobaleY=480;%***
AltezzaCamera=100;%altezza telecamera dal terreno
FOVcameraX=60;%campo di visione orizzontale webcam
FOVcameraY=60;%campo di visione verticale webcam

SogliaNero=0.3;%Soglia riconoscimento nero

ModDiffVerde=1.8; %(1.8) parametro proporzionale quantità di r e b sottratto a rgb
SogliaVerde=35;%(35) soglia riconoscimento verde
SogliaRumoreVerde=100; 

FasiFollowPercorso=40;
PmedioPercorsoX=zeros(1,FasiFollowPercorso);
PmedioPercorsoY=zeros(1,FasiFollowPercorso);
Ppercorso=zeros(2,FasiFollowPercorso+1);

ParPropCorrVerde=2;%(1.4) par. prop. correzione verde realtiva alla differenza percorsoX con PverdeX
ParDistSvoltaVerde=round(FasiFollowPercorso/10);%(/10) par. Distanza della svolta verde. Prop. a FasiFollowPercorso

%Definizione protocollo ATBmove
AvantiDX=1;
AvantiSX=2;
HoldDX=3;
HoldSX=4;
IndietroDX=5;
IndietroSX=6;
AcontinuaDX=7;
AcontinuaSX=8;
%% CALIBRAZIONE CAMERA
CampoCameraX=AltezzaCamera*tand(FOVcameraX);
CampoCameraY=AltezzaCamera*tand(FOVcameraY);
RappConvImgX=CampoCameraX/RisoluzioneGlobaleX;%rapporto di conversione orizzontale da pixel a distanza reale
RappConvImgY=CampoCameraY/RisoluzioneGlobaleY;
%% ACQUISIZIONE E SEZIONAMENTO IMMAGINE

%cam=webcam('Integrated Camera'); +++elimina+++
%ImmagineRGB=snapshot(cam);

ImmagineRGB=imresize(imread('slalom 2.png'),[RisoluzioneGlobaleY,RisoluzioneGlobaleX]);

ImmagineSN = imcomplement(im2bw(ImmagineRGB, SogliaNero)); %#ok<IM2BW>
ImmagineSudd= bwlabel(ImmagineSN,4);
NumSudd=max(max(ImmagineSudd));
CuboSudd=zeros(RisoluzioneGlobaleY,RisoluzioneGlobaleX,NumSudd);
PesoLayer=zeros(1,NumSudd);
for loopMODZ=1:NumSudd 
    for loopMODX=1:RisoluzioneGlobaleX
         for loopMODY=1:RisoluzioneGlobaleY
             if(ImmagineSudd(loopMODY,loopMODX)==loopMODZ)
             %CuboSudd(loopMODY,loopMODX,loopMODZ)=ImmagineSudd(loopMODY,loopMODX)/loopMODZ;OLD
             CuboSudd(loopMODY,loopMODX,loopMODZ)=loopMODY;
             end
         end
    end
end
for loopMOD=1:NumSudd 
    PesoLayer(loopMOD)=sum(sum(CuboSudd(:,:,loopMOD)));
end
PesoMaxLayer=max(PesoLayer(:));
IndPesoMaxLayer = find(PesoLayer(:)==PesoMaxLayer);
ImgSuddEstesa=CuboSudd(:,:,IndPesoMaxLayer); %#ok<FNDSB>
if isempty(NumSudd)==1
    ImgSuddEstesa=zeros(GlobalResY,GlobalResX);
    disp('Follow Negativo');
end
%% RICERCA VERDE
imgRosso = ImmagineRGB(:, :, 1);
imgVerde = ImmagineRGB(:, :, 2);
imgBlu = ImmagineRGB(:, :, 3);
imgSoloVerde = imgVerde - (imgRosso/ModDiffVerde + imgBlu/ModDiffVerde);
imgVerdeLogica = imgSoloVerde>SogliaVerde;
imgVerdePulita  = bwareaopen(imgVerdeLogica, SogliaRumoreVerde);

ImmagineSuddVerde= bwlabel(imgVerdePulita,4);
NumSuddVerde=max(max(ImmagineSuddVerde));
CuboSuddVerde=zeros(RisoluzioneGlobaleY,RisoluzioneGlobaleX,NumSuddVerde);
for loopMODZ=1:NumSuddVerde
    for loopMODX=1:RisoluzioneGlobaleX
         for loopMODY=1:RisoluzioneGlobaleY
             if(ImmagineSuddVerde(loopMODY,loopMODX)==loopMODZ)
             %CuboSudd(loopMODY,loopMODX,loopMODZ)=ImmagineSudd(loopMODY,loopMODX)/loopMODZ;OLD
             CuboSuddVerde(loopMODY,loopMODX,loopMODZ)=1;
             end
         end
    end
end
PmedioRigaVerde=zeros(1,NumSuddVerde);
PmedioColVerde=zeros(1,NumSuddVerde);
for loopMOD=1:1:NumSuddVerde
    [rigaVerde,colonnaVerde] = find(CuboSuddVerde(:,:,loopMOD));
    PmedioRigaVerde(loopMOD)= round(mean(rigaVerde));
    PmedioColVerde(loopMOD) = round(mean(colonnaVerde));
end
%% INDIVIDUAZIONE PERCORSO
for loopMOD=1:1:FasiFollowPercorso
    PmedioPercorsoX(1,FasiFollowPercorso) = 0;
    [riga,colonna]=find(ImgSuddEstesa((loopMOD-1)*RisoluzioneGlobaleY/FasiFollowPercorso+1:loopMOD*RisoluzioneGlobaleY/FasiFollowPercorso,:));
    PmedioPercorsoX(loopMOD)=round(mean(colonna));
    PmedioPercorsoY(loopMOD)=round(mean(riga)+RisoluzioneGlobaleY/FasiFollowPercorso*loopMOD);
end
Ppercorso(1,:)=[PmedioPercorsoX,RisoluzioneGlobaleX/2];
Ppercorso(2,:)=[PmedioPercorsoY,RisoluzioneGlobaleY];
%% CORREZIONE VERDE
DeltaXVerde=zeros(2,NumSuddVerde);
IndFaseCorrVerde=zeros(1,NumSuddVerde);
for loopMOD_E=1:1:NumSuddVerde
    for loopMOD=1:1:FasiFollowPercorso+1
        if RisoluzioneGlobaleY/FasiFollowPercorso*(loopMOD-1)<PmedioRigaVerde(loopMOD_E)&&PmedioRigaVerde(loopMOD_E)<RisoluzioneGlobaleY/FasiFollowPercorso*loopMOD
            DeltaXVerde(1,loopMOD_E)=PmedioColVerde(loopMOD_E)-Ppercorso(1,loopMOD);
            DeltaXVerde(2,loopMOD_E)=loopMOD; %la secoda riga è a scopo di debug
            IndFaseCorrVerde(loopMOD_E)=loopMOD-ParDistSvoltaVerde;%indice al quale è applicata la correzione del percorso
            if DeltaXVerde(1,loopMOD_E)<0
                Ppercorso(1,IndFaseCorrVerde(1,loopMOD_E))= round(Ppercorso(1,loopMOD)-abs(DeltaXVerde(1,loopMOD_E))*ParPropCorrVerde);
            else
                Ppercorso(1,IndFaseCorrVerde(1,loopMOD_E))= round(Ppercorso(1,loopMOD)+abs(DeltaXVerde(1,loopMOD_E))*ParPropCorrVerde);
            end
        end
    end
end
%% GENERAZIONE OUTPUT
%capovolgimento array
Ppercorso(1,:)=flip(Ppercorso(1,:));
Ppercorso(2,:)=flip(Ppercorso(2,:));
IndFaseCorrVerde=flip(IndFaseCorrVerde);
%calcolo degli angoli
deltaX=zeros(1,min(IndFaseCorrVerde)+1);
deltaY=zeros(1,min(IndFaseCorrVerde)+1);
OutAngoli=zeros(1,min(IndFaseCorrVerde)+1);
OutDistanza=zeros(1,min(IndFaseCorrVerde)+1);
OutModi=zeros(1,min(IndFaseCorrVerde)+1);
for loopMOD=1:(min(IndFaseCorrVerde)+1)
     deltaX(loopMOD)=Ppercorso(1,loopMOD+1)-Ppercorso(1,loopMOD);
     deltaY(loopMOD)=Ppercorso(2,loopMOD+1)-Ppercorso(2,loopMOD);
     OutDistanza(loopMOD)=sqrt((abs(deltaX(loopMOD)*RappConvImgX)^2-(deltaY(loopMOD)*RappConvImgY)^2));
     OutAngoli(loopMOD)=90-atand(deltaY/deltaX);
     if deltaX>=0 OutModi(loopMOD)=AcontinuaDX; %#ok<SEPEX>
     else OutModi(loopMOD)=AcontinuaSX; end %#ok<SEPEX>
end
%% PLOT DI CONTROLLO
figure(1);
%subplot(2,2,1);
%plot percorso
imshow(ImgSuddEstesa);hold on;
for loopMOD=1:FasiFollowPercorso+1
   plot(Ppercorso(1,loopMOD),Ppercorso(2,loopMOD),'b.','MarkerSize',15);
   if loopMOD<=FasiFollowPercorso
   plot([Ppercorso(1,loopMOD),Ppercorso(1,loopMOD+1)],[Ppercorso(2,loopMOD),Ppercorso(2,loopMOD+1)],'b');
   end
end
%plot verde
plot(PmedioColVerde,PmedioRigaVerde,'g.','MarkerSize',10);
end