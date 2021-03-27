%% Hämta data för portfölj
data12 = readtable("timeSeries.xlsx", "Sheet", "Problem12");

time = flip(data12.Timestamp);
S = flip(table2array(data12(:,2:end))); %seaste observationen sist

% Avkastningar för enskilda aktier 
R = S(2:end,:)./S(1:end-1,:) - ones(size(S)-[1,0]); % Aritmetiska
r = log(1+R); % Log

% Aggregerade avkastningar för likaviktad portfölj
RP = sum(R,2)/15;
rP = log(1+RP);

w = ones(15,1)/15; % vikter
V_T = 10e6; % Portföljvärde idag

%% VaR & ES
c = [0.95, 0.975, 0.99];
vol_a = sqrt(w'*cov(R)*w); %relativ volatilitet
VaR_a = norminv(c)*vol_a*V_T; % SEK

c = [0.95, 0.99];
EWMA_vol_b = ewma(0.94, rP, rP(1)^2);
EWMA_vol_b = EWMA_vol_b(501:end);

VaR_b = 1 - exp(-norminv(c).*EWMA_vol_b);
plotVaR(VaR_b, time(503:end), "B", c, rP(502:end));

VaR_c = HistSim(RP(2:end),500,c); % Vanlig Historisk simulering
plotVaR(VaR_c, time(503:end), "C", c, RP(502:end));

ES = -mean(mink(RP((end-499):end),25))*100; % väntevärde av 25 minsta observationer

EWMA_vol_d = ewma(0.94, RP, var(RP(1:20)));

VaR_d = HistSim(RP(2:end), 500, c, EWMA_vol_d); % Hull & White
plotVaR(VaR_d, time(503:end), "D", c, RP(502:end));

%% Hypotestest - Failiure rate
I_b = max(zeros(size(VaR_b)), sign(-VaR_b-RP(502:end))); % 1 vid överskridelse
I_c = max(zeros(size(VaR_c)), sign(-VaR_c-RP(502:end)));
I_d = max(zeros(size(VaR_d)), sign(-VaR_d-RP(502:end)));

alfa = [0.05, 0.01];

% Positiva värden: förkastar H0
% Rad: konfidensgrad [5%, 1%]
% Kolumn VaR-nivå [95%, 99%]
H0_FR_b = FR(I_b,c,alfa);
H0_FR_c = FR(I_c,c,alfa);
H0_FR_d = FR(I_d,c,alfa);

%% Hypotestest - Seriellt beroende
% Positiva värden: förkastar H0
% Rad: konfidensgrad [5%, 1%]
% Kolumn VaR-nivå [95%, 99%]
H0_SB_b = Christoffersen(I_b,alfa);
H0_SB_c = Christoffersen(I_c,alfa);
H0_SB_d = Christoffersen(I_d,alfa);

%% EVT
Tail = -mink(RP,ceil(length(RP)*0.05)); % dragningar från g(u+y)
u    = Tail(end);
Tail = Tail - u;
Tail = Tail(1:end-1);                     % dragningar från g(y)

% Param1: xi, param2: beta
GEV_pdf =  @(par, y) 1/par(2)*(1+par(1)*y/par(2)).^(-(par(1)+1)/par(1)); %pdf:en
GEV_inv  = @(par,y) par(2)/par(1)*((1-y)^(-par(1))-1); % inversa cdf:en
GEV_logL = @(par, Tail) -1*sum(log(GEV_pdf(par,Tail))); % -1 pga max sökes
GEV_con  = @(par, Tail) GEV_con(par, Tail); % ickelinjära bivillkor

[GEV_MLparam, logL] = fmincon(@(par) GEV_logL(par,Tail), [0.1,0.1], [],[],[],[],[],[], @(par) GEV_con(par,Tail));

nn_u = length(RP)/length(Tail); % n/n_u: antal observationer/antal observationer som överskrider u.
c = 0.99;

VaR_2a = u + GEV_inv(GEV_MLparam, 1 - (1-c)*nn_u); % relativt

%% ML för volatil period
time_GFC = [time(811),time(1071)]; %vald turbulent period
GFCtail  = -mink(RP(811:1071),ceil((1071-810)*0.05));
uGFC     = GFCtail(end);
GFCtail  = GFCtail - uGFC;
GFCtail  = GFCtail(1:end-1); %dragningar från q(y)

[GEV_GFC_ML, GFClogL] = fmincon(@(par) GEV_logL(par,GFCtail), [0.1,0.01], [],[],[],[],[],[], @(par) GEV_con(par,GFCtail));

%% Plotta GEV-tätheterna och observationer

X = linspace(0,max(Tail));
histogram(Tail,12);
hold on
plot(X, GEV_pdf(GEV_MLparam,X), X, GEV_pdf(GEV_GFC_ML,X));

title("Högersvans för förluster enligt EVT"); 
legend("Förluster i svansen för hela serien", "GPD: Hela tidsserien","GPD: 2006-2010")

%% Hämta data för optioner
data3factors =   flip(readtable("timeSeries.xlsx", "Sheet", "Problem3")); %senaste observationen sist
data3options = readtable("timeSeries.xlsx", "Sheet", "Problem3_options");

rs    = data3factors.USD3MFSR_/100;   % 3M-LIBOR: enkel ränta given i %
rc    = log(1+rs*0.25)/0.25;          % översätts till kontinuerlig
S_3   = data3factors.x_SPX;           % S&P500-kurser
VIX   = data3factors.x_VIX/100;       % årlig volatilitet given i %
h     = data3options.Holdings; % antal av varje option
q     = 0.05*ones(3,1);        % kontinuerlig utdelning
K     = [3800; 3750; 3850];    % Strike price
type  = ["C";"P";"C"];         % call eller put
i_vol = (data3options.IV_Bid + data3options.IV_Ask)/200; % implicita "mid" volatiliteter 

today  = data3factors.Timestamp(end);
expiry = ["03/19/2021"; "04/16/2021"; "09/17/2021"]; %3dje Fre i månad
T      = wrkdydif(today, expiry, [1;2;5])/252; % 1,2,5 helgdagar på NYSE

%% Beräkna pris, portföljvärde och greker
P = BSM(S_3(end),K,i_vol,rc(end),T,q,type);
V = h'*P;

delta = Greeks(S_3(end),K,i_vol,rc(end),T,q,type, "delta");
vega  = Greeks(S_3(end),K,i_vol,rc(end),T,q,type, "vega");
rho   = Greeks(S_3(end),K,i_vol,rc(end),T,q,type, "rho");

%% Riskfaktormapping
factors = diff([log(S_3),VIX,rc]); % log-avkastningar, delta-vol, delta-RFR
C_lamda = cov(factors); % deltaT = 1/252
G       = [S_3(end)*delta, vega, rho]';

vol_P = sqrt(h'*G'*C_lamda*G*h)/V; % relativt
VaR_3 = V*norminv(0.99)*vol_P; % USD

%% Marginellt bidrag
% Bidrag från varje option
grad_VaR_h  = norminv(0.99)*G'*C_lamda*G*h/(V*vol_P);

% Bidrag från varje riskfaktor (exponering mot SPX, VIX, LIBOR)
grad_VaR_hf = norminv(0.99)*C_lamda*G*h/(V*vol_P);
