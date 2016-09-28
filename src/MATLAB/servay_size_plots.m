% make servay area plots

 L = 512;


% DES SV

load('DES')
g = zeros(L,2*L-1);
w = zeros(L,2*L-1);
nbGal = zeros(L,2*L-1);

RA = RA+180;
ra1 = RA / 360 * (2*L-1);
dec1 = (90 - dec) /180 * L; % is really theta

T = size(e1,1);

amin = L;
amax = 0;
cmin = 2*L-1;
cmax = 0;

for l = 1:T
    g( floor(dec1(l)), floor(ra1(l))) = g( floor(dec1(l)), floor(ra1(l))) + weight(l)*( e1(l)-c1(l) + 1i * (e2(l)-c2(l) ) );
    w( floor(dec1(l)), floor(ra1(l))) = w( floor(dec1(l)), floor(ra1(l))) + weight(l)*(1+mcorr(l));
    nbGal(floor(dec1(l)), floor(ra1(l))) = nbGal( floor(dec1(l)), floor(ra1(l)))  + 1;
    
    if(floor(dec1(l)) < amin)
        amin = floor(dec1(l));
    end
    if(floor(dec1(l)) > amax)
        amax = floor(dec1(l));
    end
    if(floor(ra1(l)) < cmin)
        cmin = floor(ra1(l));
    end
    if(floor(ra1(l)) > cmax)
        cmax = floor(ra1(l));
    end
end
    
M = double(w == 0);
w = w + M;

m1 = 0;
m2 = 0;

for l1 = 1:L
    for l2 = 1:2*L-1
        if(M(l1,l2) == 0)
            m1 = m1 + l1;
            m2 = m2 + l2;
        end
    end
end

m1 = round(m1/sum(sum(1-M))); %central point of DES region
m2 = round(m2/sum(sum(1-M)));

g = g ./ w;


% g = g .* double( abs(g) < 0.2);
% 
% mask = double(nbGal > 100);
mask = 1-double(nbGal == 0);

g = g .* mask;

beta = (45)*pi/180;
alpha = -70*pi/180;
gamma = 0.0;
beta = (45)*pi/180;
alpha = -30*pi/180;
gamma = 0.0;

d = zeros(L, 2*L-1, 2*L-1);
d(1,:,:) = ssht_dl(squeeze(d(1,:,:)), L, 0, beta);
for el = 1:L-1
    d(el+1,:,:) = ssht_dl(squeeze(d(el,:,:)), L, el, beta);
end

mask = flip(mask,2);

flm = ssht_forward(mask,L,'Reality', true);
[flm_rotated] = ssht_rotate_flm(flm, d, alpha, gamma);
mask_sv = ssht_inverse(flm_rotated, L, 'Reality', true, 'Method', 'MWSS');

mask_sv(mask_sv > 0.5) = 1.0;
mask_sv(mask_sv < 0.5) = 0.0;

%mask_sv = flip(mask_sv,2);

figure(1)
ssht_plot_sphere(mask_sv,L,'ColourBar', false, 'Lighting', true, 'PlotSamples', false, 'Method', 'MWSS');
print(strcat('mask_plots/DES_SV_mask.eps'),'-r0','-depsc')
savefig(strcat('mask_plots/DES_SV_mask.fig'))
drawnow;
figure(1)
ssht_plot_sphere(mask_sv,L,'ColourBar', false, 'Lighting', false, 'PlotSamples', false, 'Method', 'MWSS');
axis off; 
print(strcat('mask_plots/DES_SV_mask_nl.eps'),'-r0','-depsc')
savefig(strcat('mask_plots/DES_SV_mask_nl.fig'))
drawnow;



% DES 1yr data

mask_1yr = zeros(L,2*L-1);

ang = 30*pi/180;
theta1 = 125*pi/180;
phi1 = (180+45)*pi/180;
[thetas, phis] = ssht_sampling(L, 'Grid', true);
dist = acos(sin(thetas).*sin(theta1).*cos(phis-phi1)+cos(thetas).*cos(theta1));
mask_1yr(dist<ang) = 1.0;

phi1 = 125*pi/180;
phi2 = 270*pi/180;
theta1 = 135*pi/180;
theta2 = 165*pi/180;
mask_1yr(phis > phi1 & phis < phi2 & thetas > theta1 & thetas < theta2) = 1.0;


phi1 = 225*pi/180;
phi2 = 270*pi/180;
theta1 = 120*pi/180;
theta2 = 165*pi/180;
mask_1yr(phis > phi1 & phis < phi2 & thetas > theta1 & thetas < theta2) = 1.0;

phi1 = 200*pi/180;
phi2 = 235*pi/180;
theta1 = 90*pi/180;
theta2 = 115*pi/180;
mask_1yr(phis > phi1 & phis < phi2 & thetas > theta1 & thetas < theta2) = 1.0;

phi1 = 180*pi/180;
phi2 = 235*pi/180;
theta1 = 85*pi/180;
theta2 = 95*pi/180;
mask_1yr(phis > phi1 & phis < phi2 & thetas > theta1 & thetas < theta2) = 1.0;


phi1 = 135*pi/180;
phi2 = 190*pi/180;
theta1 = 87.5*pi/180;
theta2 = 92.5*pi/180;
mask_1yr(phis > phi1 & phis < phi2 & thetas > theta1 & thetas < theta2) = 1.0;

mask_1yr = flip(mask_1yr,2);

figure(2)
ssht_plot_mollweide(mask_1yr,L);

flm = ssht_forward(mask_1yr,L,'Reality', true);
[flm_rotated] = ssht_rotate_flm(flm, d, alpha, gamma);
mask_1yr = ssht_inverse(flm_rotated, L, 'Reality', true, 'Method', 'MWSS');

mask_1yr(mask_1yr > 0.5) = 1.0;
mask_1yr(mask_1yr < 0.5) = 0.0;

figure(3)
ssht_plot_sphere(mask_1yr,L,'ColourBar', false, 'Lighting', true, 'PlotSamples', false, 'Method', 'MWSS');
print(strcat('mask_plots/DES_full_mask.eps'),'-r0','-depsc')
savefig('mask_plots/DES_full_mask.fig')
drawnow;
figure(3)
ssht_plot_sphere(mask_1yr,L,'ColourBar', false, 'Lighting', false, 'PlotSamples', false, 'Method', 'MWSS');
axis off; 
print(strcat('mask_plots/DES_full_mask_nl.eps'),'-r0','-depsc')
savefig('mask_plots/DES_full_mask_nl.fig')
drawnow;

% Euclid

load(strcat('EuclidMaskMap',int2str(L)))

mask_ec = flip(mask);


beta = (70)*pi/180;
alpha = -70*pi/180;
gamma = 0.0;

d = zeros(L, 2*L-1, 2*L-1);
d(1,:,:) = ssht_dl(squeeze(d(1,:,:)), L, 0, beta);
for el = 1:L-1
    d(el+1,:,:) = ssht_dl(squeeze(d(el,:,:)), L, el, beta);
end

beta2 = (0)*pi/180;
alpha2 = 110*pi/180;
gamma2 = 0.0;

d2 = zeros(L, 2*L-1, 2*L-1);
d2(1,:,:) = ssht_dl(squeeze(d2(1,:,:)), L, 0, beta2);
for el = 1:L-1
    d2(el+1,:,:) = ssht_dl(squeeze(d(el,:,:)), L, el, beta2);
end

flm = ssht_forward(mask_ec,L,'Reality',true);
flm = recsph_gaussian_smooth(flm, L, 0.0345);
[flm_rotated] = ssht_rotate_flm(flm, d, alpha, gamma);
[flm_rotated2] = ssht_rotate_flm(flm, d2, alpha2, gamma2);
mask_ec = ssht_inverse(flm_rotated,L,'Reality',true, 'Method', 'MWSS');
mask_ec2 = ssht_inverse(flm_rotated2,L,'Reality',true, 'Method', 'MWSS');

mask_ec(mask_ec > 0.5) = 1.0;
mask_ec(mask_ec < 0.5) = 0.0;
mask_ec2(mask_ec2 > 0.5) = 1.0;
mask_ec2(mask_ec2 < 0.5) = 0.0;


figure(4)
ssht_plot_sphere(mask_ec,L, 'Lighting', true, 'PlotSamples', false, 'Method', 'MWSS')
print(strcat('mask_plots/Euclid_1_mask.eps'),'-r0','-depsc')
savefig('mask_plots/Euclid_1_mask.fig')
drawnow;

figure(5)
ssht_plot_sphere(mask_ec2,L, 'Lighting', true, 'PlotSamples', false, 'Method', 'MWSS')
print(strcat('mask_plots/Euclid_2_mask.eps'),'-r0','-depsc')
savefig('mask_plots/Euclid_2_mask.fig')
drawnow;

figure(4)
ssht_plot_sphere(mask_ec,L, 'Lighting', false, 'PlotSamples', false, 'Method', 'MWSS')
axis off; 
print(strcat('mask_plots/Euclid_1_mask_nl.eps'),'-r0','-depsc')
savefig('mask_plots/Euclid_1_mask_nl.fig')
drawnow;

figure(5)
ssht_plot_sphere(mask_ec2,L, 'Lighting', false, 'PlotSamples', false, 'Method', 'MWSS')
axis off; 
print(strcat('mask_plots/Euclid_2_mask_nl.eps'),'-r0','-depsc')
savefig('mask_plots/Euclid_1_mask_nl.fig')
drawnow;

