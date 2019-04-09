clear all;

% Carrega as matrizes X e S (Y, no roteiro) de entrada.
load('data.mat');

% O coeficiente de regularizacao, que varia de 2^-10 a 2^+10 com incremento
% multiplicativo de 2^2.
lambda=1;
% Temos 21 matrizes W (uma para cada coeficiente de regularizacao, todas de
% 784x10 elementos.
W = zeros(785, 10, 21);
% O vetor de bias que sera concatenado na matriz X e W para nao sei o que.
vetorExtraDe1 = ones(60000,1);

% Concatenando
X = [vetorExtraDe1, X];

% O vetor que guarda os valores dos lambdas usados
lambdasNormais = zeros(1,21);

%==========CALCULANDO W PARA CADA COEFICIENTE DE REGULARIZACAO=============

i=0;
while i < 21
    
    % Multiplicamos lambda por 4 == 2^2, a cada iteracao.
    lambda = 2^(i*2-10)
    lambdasNormais(i+1) = lambda;
    
    % A equacao utilizada para realizar os minimos quadrados eh dada e
    % explicada no roteiro.
    W(:,:, i+1) = ((X(1:40000,:)'*X(1:40000,:)+lambda*eye(785))^-1)*X(1:40000,:)'*S(1:40000,:);
    
    i = i+1;    
end

% W = ((X(1:40000,:)'*X(1:40000,:)+lambda*eye(785))^-1)*X(1:40000,:)'*S(1:40000,:);

%==========FIM DO CALCULANDO W PARA CADA COEFICIENTE DE REGULARIZACAO======




%=============TAXAS DE ERROS E ACERTOS=====================================

erros = zeros(1,21);
acertos = zeros(1,21);
taxaDeAcertosNormal = zeros(1,21);
erroQuadraticoNormal = zeros(1,21);
j=1;
while j<=21
    
    erros(j) = 0;
    acertos(j) = 0;
    i = 40000 + 1;
    while i<=60000

        resultadoClassificacao = W(:,:,j)'*X(i,:)';

        [~, indiceMaxResuladoClassificacao] = max(resultadoClassificacao);
        [~, indiceMaxS] = max(S(i,:));

        if indiceMaxS == indiceMaxResuladoClassificacao
            acertos(j) = acertos(j) + 1;
        else
            erros(j) = erros(j) + 1;
        end
        
        i = i + 1;
    end
    
    erroQuadraticoNormal(j) = erros(j)^2;
    taxaDeAcertosNormal(j) = acertos(j)/(acertos(j)+erros(j));
    j = j +1;
end

[~,melhorResultadoErroQuadraticoNormal ] = min(erroQuadraticoNormal);
[~,melhorResultadoTaxaDeAcertosNormal ] = max(taxaDeAcertosNormal);

% semilogx(lambdasNormais, erroQuadraticoNormal, lambdasNormais, taxaDeAcertosNormal*5*10^7)

% title('2-D Line Plot')
% xlabel('x')
% ylabel('cos(5x)')

%=============FIM DE TAXAS DE ERROS E ACERTOS==============================





%==========REFINADO CALCULANDO W PARA CADA COEFICIENTE DE REGULARIZACAO====

W_refinado = zeros(785, 10, 21);

% O vetor que guarda os valores dos lambdas usados
lambdasRefinados = zeros(1,21);

% Faremos uma varredura em torno do minimo encontrado. Escolheremos o valor
% do coeficiente anterior a aquele que produziu o melhor resultado e iremos
% avancando de 2^0.2, multiplicativamente, ate alcancar o coeficiente de
% classificacao seguinte ao de melhor resultado.
i = melhorResultadoTaxaDeAcertosNormal - 1 -1;% Lembre que o "i" comecava em zero
                                        % na primeira varredura, entao
                                        % devemos descontar "-1" novamente,
                                        % pois os indices dos vetores em
                                        % matlab comecam em "1" (nao "0") e
                                        % queremos deixar centrado no meio
                                        % o coeficiente que gerou o melhor
                                        % resultado antes de refinar.
j=0;
while j < 21
    
    % Multiplicamos lambda por 2^0.2 a cada iteracao.
    lambda = 2^(i*2-10 + j*0.2)
    lambdasRefinados(j+1) = lambda;
    
    % A equacao utilizada para realizar os minimos quadrados eh dada e
    % explicada no roteiro.
    W_refinado(:,:, j+1) = ((X(1:40000,:)'*X(1:40000,:)+lambda*eye(785))^-1)*X(1:40000,:)'*S(1:40000,:);
    
    j = j+1;
end
%===FIM DO REFINADO CALCULANDO W PARA CADA COEFICIENTE DE REGULARIZACAO====



%=============TAXAS DE ERROS E ACERTOS=====================================

erros = zeros(1,21);
acertos = zeros(1,21);
taxaDeAcertos = zeros(1,21);
erroQuadratico = zeros(1,21);
j=1;
while j<=21
    
    erros(j) = 0;
    acertos(j) = 0;
    i = 40000 + 1;
    while i<=60000

        resultadoClassificacao = W_refinado(:,:,j)'*X(i,:)';

        [~, indiceMaxResuladoClassificacao] = max(resultadoClassificacao);
        [~, indiceMaxS] = max(S(i,:));

        if indiceMaxS == indiceMaxResuladoClassificacao
            acertos(j) = acertos(j) + 1;
        else
            erros(j) = erros(j) + 1;
        end
        
        i = i + 1;
    end
    
    erroQuadratico(j) = erros(j)^2;
    taxaDeAcertos(j) = acertos(j)/(acertos(j)+erros(j));
    j = j +1;
end

[~,melhorResultadoErroQuadratico ] = min(erroQuadratico);
[~,melhorResultadoTaxaDeAcertos ] = max(taxaDeAcertos);

dlmwrite('n175480.txt', W(:,:,melhorResultadoTaxaDeAcertosNormal), 'precision','%14.10f');

fileID = fopen('p175480.txt','w');
fprintf(fileID, '%f\n', lambdasNormais(melhorResultadoTaxaDeAcertosNormal));
fclose(fileID);

fileID = fopen('Q1_175480.txt','w');
fprintf(fileID, '%f\n%f\n', lambdasNormais(melhorResultadoErroQuadraticoNormal), lambdasNormais(melhorResultadoTaxaDeAcertosNormal));
fclose(fileID);

% semilogx(lambdasRefinados, erroQuadratico, lambdasRefinados, taxaDeAcertos*5*10^7);
% 
% title('2-D Line Plot')
% xlabel('x')
% ylabel('cos(5x)')

%=============FIM DE TAXAS DE ERROS E ACERTOS==============================

