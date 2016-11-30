function ATBmove (mode, angolo, distance, servoDX, servoSX)

%Creazione array
    
    [~, rig]=size(distance);
    modalita=zeros(1, 6);
    raggio_curva_piccola=0;
    distance_tot=zeros(1, rig);
    time=zeros(1, rig);
    time_giro=zeros(1, rig);
    velocityReal=zeros(1, rig);
    velocityMax=2*pi*raggio_ruote;
    velocityDX=zeros(1, rig);
    velocitySX=zeros(1, rig);
    
%Calcolo tempo e velocità
    
    for i=1:1:rig
        
        distance_tot(i)=distance(i)+2*pi*asse_ruote*abs(angolo(i))/360;
        time(i)=distance_tot(i)/velocityMax;
        velocityReal(i)=2*pi*raggio_curva_piccola*angolo(i)/360/time(i);
        time_giro(i)=(2*pi*raggio_curva_piccola*angolo(i)/360)/velocityReal(i);
        
     if velocityReal(1)>0

		velocityDX(1, i)=velocityReal(i)/velocityMax*0.5+0.5;
        velocitySX(1, i)=1;            
		velocityDX(7, i)=velocityReal(i)/velocityMax*0.5+0.5;
        velocitySX(7, i)=1;
   		velocityDX(2, i)=velocityReal(i)/velocityMax*0.5+0.5;
        velocitySX(2, i)=1;
   		velocityDX(8, i)=1;    
		velocitySX(8, i)=velocityReal(i)/velocityMax*0.5+0.5;

	elseif velocityReal(i)<0

		velocityDX(5, i)=0.5;
		velocitySX(5, i)=0.5-abs(velocityReal(i))/velocityMax*0.5;
        velocityDX(6, i)=0.5;
		velocitySX(6, i)=0.5-abs(velocityReal(i))/velocityMax*0.5;          
        
	else

		velocityDX(1, i)=1;
		velocitySX(1, i)=1;           
		velocityDX(2, i)=1;
        velocitySX(2, i)=1;        
		velocityDX(5, i)=0;
		velocitySX(5, i)=0;          
		velocityDX(6, i)=0;            
		velocitySX(6, i)=0; 
		velocityDX(7, i)=1;            
		velocitySX(7, i)=1;
		velocityDX(8, i)=1;            
		velocitySX(8, i)=1;       

    end       

       
    time(3)=(angolo(1)*2*pi*(asse_ruote/2)/360)/velocityMax;
    time(4)=(angolo(1)*2*pi*(asse_ruote/2)/360)/velocityMax;
    
    velocityDX(3)=1;
    velocitySX(3)=0; 
    
    velocityDX(4)=0;
    velocitySX(4)=1; 
    
%Creazione modi 
    
    modalita(1)=[time(1), time_giro(1), velocityDX(1), velocitySX(1)];
    modalita(2)=[time(2), time_giro(2), velocityDX(2), velocitySX(2)];
    modalita(3)=[time(3), time_giro(3), velocityDX(3), velocitySX(3)];
    modalita(4)=[time(4), time_giro(4), velocityDX(4), velocitySX(4)];
    modalita(5)=[time(5), time_giro(5), velocityDX(5), velocitySX(5)];
    modalita(6)=[time(6), time_giro(6), velocityDX(6), velocitySX(6)];
    modalita(7)=[time(7), time_giro(7), velocityDX(7), velocitySX(7)];
    modalita(8)=[time(8), time_giro(8), velocityDX(8), velocitySX(8)];
    
%Movimento
  
    for a=1:1:rig

        cronometro=tic;
        cronometro_giro=tic;

        time_cronometro=toc(cronometro);

        while time_cronometro<time(mode)

            cronometro2=tic;
            time_cronometro_giro=toc(cronometro_giro);        

            while time_cronometro_giro<time_giro(mode) && time_giro(mode)~=0

                cronometro_giro2=tic;

                writePosition(servoDX, velocityDX(mode, a));
                writePosition(servoSX, velocitySX(mode, a));

                if modo==7 || modo==8

                    writePosition(servoDX, 0.75);
                    writePosition(servoSX, 0.75);

                end

                time_cronometro_giro2=toc(cronometro_giro2);
                time_cronometro_giro=time_cronometro_giro+time_cronometro_giro2;

            end

            toc(cronometro_giro);

            switch modo

                case 1; 2; 7; 8; 

                    writePosition(servoDX, 1);
                    writePosition(servoSX, 1);

                case 5; 6; 

                    writePosition(servoDX, 0);
                    writePosition(servoSX, 0);

            end

            time_cronometro2=toc(cronometro2);
            time_cronometro=time_cronometro+time_cronometro2;  

        end

        toc(cronometro);
        
        ATBckobstacle();
        ATBckarena();
        
        if ATBckobstacle()==1 || ATBckarena()==1
            
            break;
            
        end
    
    end
    
end


    
    
    
    
