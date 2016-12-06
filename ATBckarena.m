function [mode, angolo, distance]=ATBckarena (camera)

    global RisoluzioneGlobaleX RisoluzioneGlobaleY
    camera=webcam('Nome_Webcam');
    image=snapshot(camera);
    grayMin=105;
    grayMax=220;
    gray=zeros(RisoluzioneGlobaleY, RisoluzioneGlobaleX);   
   
     for LoopY=1:1:RisoluzioneGlobaleY
        for LoopX=1:1:RisoluzioneGlobaleX
            if grayMin<=image(LoopY, LoopX, 1)&& ...
               grayMin<=image(LoopY, LoopX, 2)&& ...
               grayMin<=image(LoopY, LoopX, 3)&& ...
               grayMax>=image(LoopY, LoopX, 1)&& ...
               grayMax>=image(LoopY, LoopX, 2)&& ...
               grayMax>=image(LoopY, LoopX, 3)
           
                gray(LoopY, LoopX)=1;
            end
        end
     end

    [riga, colonna]=find(gray(:, 1:RisoluzioneGlobaleX/2));    
    ya=round(mean(riga));
    xa=round(mean(colonna));    
    [riga2, colonna2]=find(gray(:, RisoluzioneGlobaleX/2+1:RisoluzioneGlobaleX));    
    yb=round(mean(riga2));
    xb=round(mean(colonna2))+RisoluzioneGlobaleX/2;
    coefficiente_angolare=(yb-ya)/(xb-xa);
    angolo=atand(coefficiente_angolare);
    
    if angolo>0        
        mode=3;
        distance=0;        
    elseif angolo<0      
        mode=4;
        distance=0;        
    end    
    ATBmove(mode, angolo, distance);
end