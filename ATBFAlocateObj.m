function [PmedioYGrigio,PmedioXGrigio]=ATBFAlocateObj(cam)
%close %***
%clear %***
%clc %***
%% DEFINIZONE VARIABILI
global RisoluzioneGlobaleX;%risoluzione globale immagini x
global RisoluzioneGlobaleY;%risoluzione globale immagini y
RisoluzioneGlobaleX=640;%*** aggiungi al setup hardware
RisoluzioneGlobaleY=480;%***
AltezzaCamera=200;%altezza telecamera dal terreno
FOVcameraX=60;%campo di visione orizzontale webcam
FOVcameraY=60;%campo di visione verticale webcam
disCameraForo=40;%distanza punto di cattura e punto di osservazione in mm(38-40)
minGrigio=120;%+++definisci+++
maxGrigio=220;%+++definisci+++
%% CALIBRAZIONE CAMERA
CampoCameraX=AltezzaCamera*tand(FOVcameraX);
CampoCameraY=AltezzaCamera*tand(FOVcameraY);
RappConvImgX=CampoCameraX/RisoluzioneGlobaleX;%rapporto di conversione orizzontale da pixel a distanza reale
RappConvImgY=CampoCameraY/RisoluzioneGlobaleY;
%% ANALISI IMMAGINE
%ImmagineRGB=snapshot(cam);s
ImmagineRGB=imresize(imread('testObj.png'),[RisoluzioneGlobaleY,RisoluzioneGlobaleX]);
imgLogica=zeros(480,640);
for Xmodificatore = 1:640
    for Ymodificatore = 1:480
        if ((minGrigio<ImmagineRGB(Ymodificatore,Xmodificatore,1)&&ImmagineRGB(Ymodificatore,Xmodificatore,1)<maxGrigio)&&...
            (minGrigio<ImmagineRGB(Ymodificatore,Xmodificatore,2)&&ImmagineRGB(Ymodificatore,Xmodificatore,2)<maxGrigio)&&...
            (minGrigio<ImmagineRGB(Ymodificatore,Xmodificatore,3)&&ImmagineRGB(Ymodificatore,Xmodificatore,3)<maxGrigio))
           imgLogica(Ymodificatore,Xmodificatore) = true;
        end
    end
end
imgLogica = bwareaopen(imgLogica, 1000);%+++definisci+++ oppure sostituisci con meccanismo detect maggiore
% calcolo posizione relativa
[rigaGrigio,colonnaGrigio] = find(imgLogica);
PmedioXGrigio =  mean(rigaGrigio)*RappConvImgX-RisoluzioneGlobaleX/2;
PmedioYGrigio = (RisoluzioneGlobaleY-mean(colonnaGrigio))*RappConvImgY+disCameraForo;
%% DEBUG PLOT
% figure
% imshow(ImmagineRGB);
% figure
% imshow(imgLogica);
% %end