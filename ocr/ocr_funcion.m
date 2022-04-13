function texto = ocr_funcion(nombre)
    % Función que devuelve una cadena de caracteres correspondiente al texto de la imagen 
    % Parametros de entrada:
    %   nombre = nombre de la imagen cuyo texto quiere ser extraido
    % Parametros de salida:
    %   texto = cadena de caracteres que contiene el texto obtenido

    im = imread(nombre);                                                    %Leemos la imagen de entrada
    files = dir('*.jpg');                                                   %Leemos el path de las letras de prueba
    names = {files.name};
    
    im=im2bw(im);                                                           %Convertimos la imagen a binaria
    im=imcomplement(im);                                                    %Invertimos la imagen

    for i=1:height(im)                                                      %Sumamos todos los elementos de cada fila y aplicamos umbral
        x(i)=sum(im(i,:))-10;
    end

    x=sign(x);                                                              %Convertimos en senal cuadrada
    
    texto="";
    anterior1=0;
    anterior=0;
    espacios=0;

    k=1;

    for j=1:length(x)                                                       %Bucle que recorre la senal cuadrada para elegir las filas
        if x(j)>0                                                           %Si es 1 añadimos esa fila a la imagen que 
            im2(k,:)=im(j,:);                                               %contendra la fila de esta vuelta del bucle
            k=k+1;
            anterior1=1;
        end
        if anterior1==1 && x(j)<0                                           %Si han acabado los 1 significa que la fila ha acabado
                                                                            %y por tanto pasa a analizarse todas sus letras
            anterior1=0;
            k=1;

            for i=1:width(im2)                                              %Sumamos todos los elementos de cada columna y aplicamos umbral
                t(i)=sum(im2(:,i))-1;
            end
            t=sign(t);                                                      %Convertimos en senal cuadrada
            
           
            for l=1:length(t)                                               %Bucle que recorrela senal cuadrada para elegir letras
                if t(l)>0                                                   %Si es 1 añadimos esa columna a la imagen que
                     if k==1                                                %contendra la letra de esta vuelta del bucle
                        if espacios>5 && espacios<50                        %Anadimos espacios si se supera el umbral de espacios en blanco
                            texto = texto + ' ';
                        end
                     end
                     
                    espacios=0;

                    im3(:,k)=im2(:,l);
                    k=k+1;
                    anterior=1;

                else
                    espacios=espacios+1;
                end
                if anterior==1 && t(l)<0                                    %Si han acabado los 1 significa que la letra ha acabado y por
                                                                            %tanto pasa a realizarse la correlacion con la bateria de letras
                    for p=1:numel(names)                                    %Bucle que sirve para elegir la letra p-esima del abecedario
                        clear imagen
                        imagen = imread(names{p});
                        imagen = im2bw(imagen);

                        tama=size(im3);
                        c=imresize(imagen, tama);                           %Se iguala el tamaño de las imagenes a comparar
                        
                            ands=c & im3;                                   %Correlacion con and
                            xors=xor(c,im3);                                %Correlacion con xor
                            
                        if tama(1)/tama(2)>3                                %Caso especial para la 'I'
                            
                            correlaciones(:)=0;
                            correlaciones1(:)=0;
                            andsSumados(:)=0 ;
                            xorsSumados(:) = 0;
                            
                            correlaciones(9)=1;
                            correlaciones1(9)=1;
                            andsSumados(9)= 1;
                            xorsSumados(9) = 1;
                            
                        else
                            
                            correlaciones(9)=0;
                            correlaciones1(9)=0;
                            andsSumados(9)= 0;
                            xorsSumados(9) = 0;
                            
                            correlaciones1(p)=corr2(im3,c);                 %Calculo de correlaciones
                            correlaciones(p)=sum(sum((im3-0.5).*(c-0.5)));
                            andsSumados(p) = sum(ands(:)==1);
                            xorsSumados(p) = sum(xors(:)==1);
                        end
                    end

                    M = abs(max(xorsSumados));                                   %Normalizar vectores de correlaciones
                    xorsSumados = xorsSumados/M;
                    M = abs(max(correlaciones1));
                    correlaciones1=correlaciones1/M;
                    M = abs(max(correlaciones));
                    correlaciones=correlaciones/M;
                    M = abs(max(andsSumados));
                    andsSumados=andsSumados/M;
                    
                    correlaciones=correlaciones+correlaciones1+andsSumados-xorsSumados;
                    [M,I] = max(correlaciones);                             %Calculo del indice de la letra con mayor correlacion

                    texto = texto +names{I}(1);                             %Actualizamos el texto
                    anterior=0;
                    k=1;
                    clear im3;
                    
                end
            end

            texto = texto + newline;

        end
    end

    texto=char(texto);                                                      %Convertimos a cadena de caracteres
    texto=texto(2:end);





