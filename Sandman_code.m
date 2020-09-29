%This program plays Mr. Sandman and writes it to an audio file. The
%creation of the song is generally broken up into 4 measure chunks, which
%is all concatenated at the end. The song is in A major (32 measures) at 
%first and then moves to D major (32 measures plus 4 measures for ending),
%with an intro at the beginning of each considered separately (measure 1
%starts after the intro).
%For the first half of the song, song vectors are named
%mAtB which represents measures A to B (ex. m5t8 is measures 5 to 8). The 
%chords used in that section are
%simply named a1 - an, a for A major, and the numbering continues through
%the first half. In the second half of the song in D, I use the same naming
%conventions, except name 4 bar section dmAtB, starting from measure 1
%again (ex. dm9-12 is measures 9 to 12 in the D Major section). The chords
%in that section are named d1 to dn, because they are in the key of D. Many
%of the chords are reused by multiplying the corresponding a chord by the
%variable atod to get the d chord. atod is the ratio between a note and the
%note a fifth down, which is the distance from A to D. 
%Each four measure section generally consists of three parts, melody (which is all
%the chords using the Horn instrument, meant to emulate the four-part singing), 
%bass (which uses the Guitar instrument defined below), and percussion,
%which is either a snare drum or ride cymbol. This song changes feel in
%different section, in the second half of the D major section it goes into
%a half-time groove, meaning the beat stays the same but it feels half as
%fast, even though the chords are moving at the same speed.

global fs; %sampling rate
fs = 8000;
global QNL; % Quarter Note Length
QNL = 0.25;

%Defines the relative amplitudes of the first i harmonics of the
%instrument. Passed into every function that uses the function note(), and
%determines the timbre of the note.
Drone = [0];
Clarinet = [0.35,0.25,0.01,0.075]; %,0.2,0.02];
Clarinet2 = [0.01 0.95 0.15 0.5 0.15 0.25 0.05 0.25];
Horn = [0.4,0.23,0.21,0.075];
Flute = [9,3.5,5,2,0.3,0.1];
Guitar = [0.65,1.25,0.13,0.13,0.12,0,0.01];
Piano = [0.1,0.325,0.05,0.04,0.04,0,0.02];
Sax = [0.75 0.025];
Test = [0,2,0.5,0.4,1,0.1];
Sawtooth = sawtooth();

%Defines the low and high frequencies for random noise, and the rate of
%exponential decay for a percussion instrument. Passed into function
%noise() or drumLine() to create persussion sound
Snare = [300, 2600, 30];
Ride = [1500, 3500, 8];
BassDrum = [50, 300, 8];

%Define the frequencies of 1 octave starting at 440. To play other octaves
%multiply the frequency by a power of 2
fA = 440;
fBb = fA * 2 ^ (1/12);
fAs = fBb;
fB = fA * 2 ^ (2/12);
fC = fA * 2 ^ (3/12);
fCs = fA * 2 ^ (4/12);
fDb = fCs;
fD = fA * 2 ^ (5/12);
fDs = fA * 2 ^ (6/12);
fEb = fDs;
fE = fA * 2 ^ (7/12);
fF = fA * 2 ^ (8/12);
fFs = fA * 2 ^ (9/12);
fGb = fFs;
fG = fA * 2 ^ (10/12);
fGs = fA * 2 ^ (11/12);
fAb = fGs;

%The next few blocks of code initialize 4-measure drum loops that are added
%to most 4-measure sections of the song.
snare1 = noise(1, Snare);
snare = [0.2.*snare1 snare1 0.2.*snare1 snare1];
snare = 0.05.*[snare snare snare snare];
ride1 = [1 54/80 26/80 1 54/80 26/80];
rideM1 = 0.1.*drumLine(ride1, Ride);
rideM4 = [rideM1 rideM1 rideM1 rideM1];
rideM3 = [rideM1 rideM1 rideM1 0.1.*noise(4, Ride)];

snareT1 = noise(1.5, Snare);
snareT2 = noise(0.5, Snare);

shuffle = 0.01.*[snareT1 snareT2 8.*snareT1 snareT2];
shuffle = [shuffle shuffle shuffle shuffle];

%This is the beginning of the where the harmonic content of the song begins
%to be assigned. The naming conventions do not start until after the intro
lineNotes = 2.*[fA fCs fE fGs fFs fE fCs fA fGs*(1/2) fC fDs fGs 0]; 
lineTimes = [1 1 1 1 1 1 1 1 1 1 1 1 4];
disp(length(lineTimes));
y1 = makeLine(lineTimes, lineNotes, Sax, 13, 0);
y2 = makeLine(lineTimes, lineNotes, Drone, 15, 0);
z = y2;

intro1Notes = [fA fCs fE fGs];
intro1t2 = rollChord(1, intro1Notes, Clarinet, 8, 0);
intro2Notes = [fFs fE fCs fA];
intro2Times = [1 1 1 1];
intro2 = [rest(4) makeLine(intro2Times, intro2Notes, Clarinet, 0, 0)];
intro1t2 = intro1t2 + intro2;
intro3Notes = [fB fD fFs];
intro3t4 = rollChord(1, intro3Notes, Clarinet, 6, 0);
intro4Notes = [0 fA*2 fGs];
intro4Times = [3 1 2];
intro4 = makeLine(intro4Times, intro4Notes, Clarinet, 2,0);
intro1t4 = [intro1t2 (intro3t4+intro4) rest(2)];

%create m. 1 to 4 Bass
m1t4BassNotes = (1/8)*[fA*2 fE fA fE fFs fG fGs fGs fGs fGs];
m1t4BassTimes = [2 2 1 1 1 1 2 2 2 2];
m1t4Bass = makeLine(m1t4BassTimes, m1t4BassNotes, Guitar, 10, 0);

%m. 1 to 8 chords
a1 = [fGs*0.5 fBb fD fF];
a2 = [fGs*0.5 fBb fD fFs];
a3 = [fA fCs fE fGs];
a4 = [fA fCs fE fFs];
a5 = [fFs*0.5 fC fGs];
a6 = [fEb*0.5 fC fFs];
a7 = [fF*0.5 fCs fA*2];
a8 = [fF*0.5 fB fGs];
a9 = [fFs*0.5 fAs fD];
a10 = [fE*0.5 fAs fCs];

c1 = buildChord(1, a1, Horn, 0, 12);
c2 = buildChord(1, a2, Horn, 0, 12);

c3 = buildChord(1, a3, Horn, 0, 12);
c4 = buildChord(6, a4, Horn, 0, 12);
c5 = buildChord(1, a5, Horn, 0, 12);
c5b = buildChord(1.5, a5, Horn, 0, 12);
c6 = buildChord(1, a6, Horn, 0, 12);

c7 = buildChord(1, a7, Horn, 0, 12);
c8 = buildChord(1, a8, Horn, 0, 12);
c9 = buildChord(2, a9, Horn, 0, 12);
c9b = buildChord(4, a9, Horn, 0, 12);
c10 = buildChord(1, a10, Horn, 0, 12);
m56 = [rest(2) c1 c2 c3 c4 rest(1) c5 c5 c6 c5 rest(4) rest(1) c7 c7 c8 c7 c7 rest(1) c8 c9 c10 c9];
intro = [intro1t4 intro1t4] + [rest(28) rest(2) c1 c2];

m1t4 = 0.4.*[c3 c4 rest(1) c5 c5 c6 c5b rest(3.5)] + 4.*m1t4Bass + 2.*y2 + snare;
m5t8 = [rest(1) c7 c7 c8 c7 c7 rest(1) c8 c9 c10 c9b rest(1)];

m5t8BassNotes = (1/8).*[fCs fCs fCs fCs fFs fFs fFs fFs];
m5t8BassTimes = [2 2 2 2 2 2 2 2];
m5t8Bass = makeLine(m5t8BassTimes, m5t8BassNotes, Guitar, 10, 0);

m5t8 = 0.4.*m5t8 + 4.*m5t8Bass + snare;

%chords for m9t12
a11 = [fFs*0.5 fB fDs fGs];
a12 = [fFs*0.5 fA*0.5 fDs fFs];
a13 = [fE*0.5 fGs*0.5 fCs];
a14 = [fD*0.5 fGs*0.5 fB];
a15 = [fGs*0.5 fB fE];

c11 = buildChord(1, a11, Horn, 0, 12);
c12 = buildChord(1, a12, Horn, 0, 12);
c13 = buildChord(1, a13, Horn, 0, 12);
c13b = buildChord(2, a13, Horn, 0, 12);
c14 = buildChord(1, a14, Horn, 0, 12);
c15 = buildChord(3, a15, Horn, 0, 12);

%melody for measures 9 to 12
m9t12 = [rest(1) c11 c11 c12 c11 rest(2) c12 c13 c13 c14 c13b c15];

%bass line for 9 to 12
m9t12BassNotes = (1/8).*[fB fB fB fB fE fE fE fE];
m9t12BassTimes = [2 2 2 2 2 2 2 2];
m9t12Bass = makeLine(m9t12BassTimes, m9t12BassNotes, Guitar, 10, 0);

%combine all the parts for measures 9 to 12
m9t12 = 0.4.*m9t12 + 4.*m9t12Bass + snare;

%chords for m13t16
a16 = [fA fCs fFs fB*2];
a17 = [fA fCs fE fA*2];
a18 = [fF*0.5 fA fEb fC*2];
a19 = [fE*0.5 fE fGs fCs*2];
a20 = [fE*0.5 fD fGs fB*2];

c16 = buildChord(1, a16, Horn, 0, 12);
c17 = buildChord(1, a17, Horn, 0, 12);
c18 = buildChord(2, a18, Horn, 0, 12);
c19 = buildChord(1, a19, Horn, 0, 12);
c20 = buildChord(3, a20, Horn, 0, 12);
m13t16 = [rest(1) c16 c16 c17 c16 c16 c16 c17 c18 c18 c19 c20];

m13t16BassNotes = (1/8).*[fA*2 fA*2 fA*2 fA*2 fF fF fE fE];
m13t16BassTimes = [2 2 2 2 2 2 2 2];
m13t16Bass = makeLine(m13t16BassTimes, m13t16BassNotes, Guitar, 10, 0);
m13t16 = 0.4.*m13t16 + 4.*m13t16Bass + snare;

m17t20 = m1t4;
m21t24 = m5t8;

%m25t29;
a21 = [fD*0.5 fFs*0.5 fB];
a22 = [fD*0.5 fFs*0.5 fB fD];
a23 = [fD*0.5 fA fB fFs];
a24 = [fD*0.5 fFs*0.5 fB fA*2];
a25 = [fD*0.5 fA fF fB*2];
a26 = [fF*0.5 fB fD fA*2];
a27 = [fF*0.5 fA fD fB*2];

c21 = buildChord(2, a21, Horn, 0, 12);
c22 = buildChord(1, a22, Horn, 0, 12);
c23 = buildChord(2, a23, Horn, 0, 12);
c23b = buildChord(1, a23, Horn, 0, 12);
c24 = buildChord(1, a24, Horn, 0, 12);
c25 = buildChord(4, a25, Horn, 0, 12);
c26 = buildChord(1, a26, Horn, 0, 12);
c27 = buildChord(1, a27, Horn, 0, 12);

m25t28 = [c21 c22 c23 c24 c24 c23b c25 rest(2) c26 c27];
m25t28BassNotes = (1/4).*[fB fB fB fB fF*0.5 fF*0.5 fF*0.5 fF*0.5];
m25t28BassTimes = [2 2 2 2 2 2 2 2];
m25t28Bass = makeLine(m25t28BassTimes, m25t28BassNotes, Guitar, 10, 0);

m25t28 = 0.4.*m25t28 + 4.*m25t28Bass + snare;

%m29t32

a28 = [fA fE fCs*2];
a29 = [fA fCs fE fA*2];

c28 = buildChord(2, a28, Horn, 0, 12);
c28b = buildChord(1, a28, Horn, 0, 12);
c29 = buildChord(1, a29, Horn, 0, 12);
c29b = buildChord(5, a29, Horn, 0, 12);

m29t32 = [c28 c28 c28b c29 c28b c29b rest(4)];

m29t32BassNotes = (1/4).*[fE*0.5 fE*0.5 fB fE*0.5 fA 0];
m29t32BassTimes = [2 2 2 2 2 6];
m29t32Bass = makeLine(m29t32BassTimes, m29t32BassNotes, Guitar, 10, 0);

m29t32 = 0.4.*m29t32 + 4.*m29t32Bass + snare;

atod = 2 ^ (-7/12);
transitionNotes = atod.*[0 fE*0.5 fFs*0.5 fGs*0.5];
transitionTimes = [13 1 1 1];
transition = makeLine(transitionTimes, transitionNotes, Clarinet, 4, 0);

m29t32 = m29t32 + 3.*transition;

m1t16CounterNotes = (1/2).*[0 fGs*0.5 fAs fC fCs 0 fFs*0.5 fGs*0.5 fAs fB 0 fE*0.5 fFs*0.5 fGs*0.5 fA 0];
m1t16CounterTimes = [13 1 1 1 1 12 1 1 1 1 12 1 1 1 1 15];
m17t32CounterNotes = (1/2).*[0 fGs*0.5 fAs fC fCs 0 fFs*0.5 fGs*0.5 fAs fB 0];
m17t32CounterTimes = [13 1 1 1 1 12 1 1 1 1 31];

m1t16Counter = makeLine(m1t16CounterTimes,m1t16CounterNotes,Clarinet, 8, 0);
m17t32Counter = makeLine(m17t32CounterTimes,m17t32CounterNotes,Clarinet, 8, 0);
counterLine = [m1t16Counter m17t32Counter];

dintro1Notes = atod.*intro1Notes;
dintro1t2 = rollChord(1, dintro1Notes, Clarinet, 8, 0);
dintro2Notes = atod.*intro2Notes;
dintro2 = [rest(4) makeLine(intro2Times, dintro2Notes, Clarinet, 0, 0)];
dintro1t2 = dintro1t2 + dintro2;

dintro3Notes = atod.*intro3Notes;
dintro3t4 = rollChord(1, dintro3Notes, Clarinet, 6, 0);
dintro4Notes = atod.*intro4Notes;
dintro4 = makeLine(intro4Times, dintro4Notes, Clarinet, 2, 0);
dintro1t4 = [dintro1t2 (dintro3t4+dintro4) rest(2)];

dintro = 3.*[dintro1t4 dintro1t4];

d1 = atod.*a1;
d2 = atod.*a2;
d3 = atod.*a3;
d4 = atod.*a4;
d5 = atod.*a5;
d6 = atod.*a6;
d7 = atod.*a7;
d8 = atod.*a8;
d9 = atod.*a9;
d10 = atod.*a10;

dc1 = buildChord(1, d1, Horn, 0, 12);
dc2 = buildChord(1, d2, Horn, 0, 12);
dc3 = buildChord(1, d3, Horn, 0, 12);
dc4 = buildChord(6, d4, Horn, 0, 12);
dc5 = buildChord(1, d5, Horn, 0, 12);
dc6 = buildChord(1, d6, Horn, 0, 12);
dc7 = buildChord(1, d7, Horn, 0, 12);
dc8 = buildChord(1, d8, Horn, 0, 12);
dc9 = buildChord(2, d9, Horn, 0, 12);
dc9b = buildChord(4, d9, Horn, 0, 12);
dc10 = buildChord(1, d10, Horn, 0, 12);

dm1t4 = [dc3 dc4 rest(1) dc5 dc5 dc6 dc5 rest(4)];
dm5t8 = [rest(1) dc7 dc7 dc8 dc7 dc7 rest(1) dc8 dc9 dc10 dc9b rest(1)];

dintro4BassNotes = (1/8).*[0 fB*2 fA*2 fFs];
dintro4BassTimes = [29 1 1 1];
dintroBass = makeLine(dintro4BassTimes, dintro4BassNotes, Guitar, 10, 0);
dintroT = [rest(30) dc1 (dc2+0.08.*noise(1, Ride))];
dintro = 0.4.*dintro + 4.*dintroBass+0.4.*dintroT;

d11 = atod.*a11;
d12 = atod.*a12;
d13 = atod.*a13;
d14 = atod.*a14;
d15 = atod.*a15;
dc11 = buildChord(1, d11, Horn, 0, 12);
dc12 = buildChord(1, d12, Horn, 0, 12);
dc13 = buildChord(1, d13, Horn, 0, 12);
dc13b = buildChord(2, d13, Horn, 0, 12);
dc14 = buildChord(1, d14, Horn, 0, 12);
dc15 = buildChord(3, d15, Horn, 0, 12);
dm9t12 = [rest(1) dc11 dc11 dc12 dc11 rest(2) dc12 dc13 dc13 dc14 dc13b dc15];

WalkingBass = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]; %16 quarter notes for walking bass
dm1t4BassNotes = (1/8).*[fD fFs fA*2 fFs fD fA*2 fFs fD fCs fF fGs fF fCs fB*2 fGs fF];
dm5t8BassNotes = (1/8).*[fFs fAs*2  fD*2 fAs*2 fFs fD*2 fC*2 fBb*2 fB*2 fCs*2 fDs*2 fCs*2 fB*2 fA*2 fG fFs];
dm9t12BassNotes = (1/8).*[fE fGs fB*2 fGs fE fFs fG fGs fA*2 fCs*2 fE*2 fCs*2 fA*2 fA*2 fB*2 fCs*2];

dm1t4Bass = makeLine(WalkingBass, dm1t4BassNotes, Guitar, 10, 0);
dm5t8Bass = makeLine(WalkingBass, dm5t8BassNotes, Guitar, 10, 0);
dm9t12Bass = makeLine(WalkingBass, dm9t12BassNotes, Guitar, 10, 0);

dm1t4 = 0.4.*dm1t4 + 2.*dm1t4Bass + 0.02.*rideM4 + 0.2.*snare;
dm5t8 = 0.4.*dm5t8 + 2.*dm5t8Bass + 0.02.*rideM4 + 0.2.*snare;
dm9t12 = 0.4.*dm9t12 + 2.*dm9t12Bass + 0.02.*rideM4 + 0.2.*snare;

d16 = atod.*a16;
d17 = atod.*a17;
d18 = atod.*a18;
d19 = atod.*a19;
d20 = atod.*a20;

dc16 = buildChord(1, d16, Horn, 0, 12);
dc17 = buildChord(1, d17, Horn, 0, 12);
dc18 = buildChord(2, d18, Horn, 0, 12);
dc19 = buildChord(1.4, d19, Horn, 0, 12);
dc20 = buildChord(2.6, d20, Horn, 0, 12);
dm13t16 = [rest(1) dc16 dc16 dc17 dc16 dc16 dc16 dc17 dc18 dc18 dc19 dc20];

dm13t16BassNotes = (1/8).*[fD*2 fA*2 fFs fG fGs fA*2 fD*2 fB*2 fBb*2 fD*2 fF*2 fG*2 fA*2 fCs*2 fE*2 fFs*2];
dm13t16Bass = makeLine(WalkingBass, dm13t16BassNotes, Guitar, 10, 0);

triplets = [54/80 54/80 52/80];
trip = drumLine(triplets, Snare);
trip4 = [trip trip trip 5.*noise(2, Snare)];
crescendo = cresc(8, 0.02, 1);
trip4 = trip4.*crescendo;
trip4 = [rest(8) trip4];

dm13t16 = 0.4.*dm13t16 + 0.1.*trip4 + 2.*dm13t16Bass + 0.02.*rideM4 + 0.2.*snare;
dm13t16 = cresc(16, 0.5, 2).*dm13t16;
dm1t16CounterNotes = 1.*[0 fCs fB fCs fB fGs*0.5 fF*0.5 fFs*0.5 0 fG fFs fG fFs fDs fB fE 0 fB fA fB fA fD*0.5 0];
dm1t16CounterTimes = [13 (54/80) (26/80) (54/80) (26/80) (54/80) (26/80) 1 12 (54/80) (26/80) (54/80) (26/80) (54/80) (26/80) 1 13 (54/80) (26/80) (54/80) (26/80) 1 15];
dm1t16Counter = makeLine(dm1t16CounterTimes, dm1t16CounterNotes, Guitar, 15, 0);

%17 to end, but in half time
d21 = d3.*2;
d22 = d4.*2;
d23 = d5.*2;
d24 = d6.*2;

dc21 = buildChord(1.5, d21, Horn, 0, 0);
dc22 = buildChord(6.5, d22, Horn, 0, 12);
dc23 = buildChord(1.5, d23, Horn, 0, 0);
dc23c = buildChord(0.5, d23, Horn, 0, 0);
dc23b = 0;
for i = 1:3
    dc23b = dc23b + slideNote(d23(i), d23(i)*(2^(-5/12)),0.5,0.5,Horn);
end
dc24 = buildChord(1.5, d24, Horn, 0, 0);

dm17t20BassNotes = (1/4).*[fD fA fCs fB fA fCs fF fCs fCs*0.5 fG*0.5];
dm17t20BassTimes = [1.7 0.3 2 2 2 2 2 1.7 0.3 2];
dm17t20Bass = makeLine(dm17t20BassTimes, dm17t20BassNotes, Guitar, 10, 0);

dm17t20 = [dc21 dc22 dc23 2.*dc23c dc24 2.*dc23c 2.*dc23 dc23b rest(2)];
dm17t20 = 0.4.*dm17t20 + 2.*shuffle + 2.*dm17t20Bass;

%dm21t24
d25 = d7.*2;
d26 = d8.*2;
d27 = d9.*2;
d28 = d10.*2;

%fix times
dc25 = buildChord(0.5, d25, Horn, 0, 0);
dc25b = buildChord(1.5, d25, Horn, 0, 0);
dc25c = buildChord(0.5, d25, Horn, 8, 0);
dc26 = buildChord(0.5, d26, Horn, 0, 0);
dc27 = buildChord(1.5, d27, Horn, 0, 0);
dc27b = buildChord(4, d27, Horn, 0, 12);
dc27c = buildChord(0.5, d27, Horn, 0, 0);
dc28 = buildChord(1.5, d28, Horn, 0, 0);

dm21t24 = [rest(1.5) dc25 dc25b dc26 dc25b 4.*dc25c rest(1.5) dc26 dc27 dc27c dc28 dc27b rest(0.5)];

dm21t24BassNotes = (1/4).*[fFs*0.5 fGs*0.5 fAs fCs fB fB fA fG*0.5 fFs*0.5];
dm21t24BassTimes = [2 2 2 2 1.6 0.4 2 2 2];
dm21t24Bass = makeLine(dm21t24BassTimes, dm21t24BassNotes, Guitar, 10, 0);

dm21t24 = 0.4.*dm21t24 + 2.*shuffle + 2.*dm21t24Bass;

%dm25t28
d29 = (2*atod).*a21;
d30 = (2*atod).*a22;
d31 = (2*atod).*a23;
d32 = (2*atod).*a24;
d33 = (2*atod).*a25;
d34 = (2*atod).*a26;
d35 = (2*atod).*a27;

dc29 = buildChord(1.4, d29, Horn, 0, 0);
dc30 = buildChord(1.4, d30, Horn, 0, 0);
dc31 = buildChord(1.5, d31, Horn, 0, 0);
dc32 = buildChord(0.7, d32, Horn, 0, 0);
dc33 = buildChord(5.5, d33, Horn, 0, 12);
dc34 = buildChord(1.5, d34, Horn, 0, 0);
dc35 = buildChord(0.5, d35, Horn, 0, 0);

dm25t28 = [dc29 rest(0.6) dc30 rest(0.6) dc31 1.5.*dc32 rest(1.3) dc33 rest(1) dc34 2.*dc35];

dm25t28BassNotes = (1/4).*[fE*0.5 fFs*0.5 fG*0.5 fB fG*0.5 fBb fA fG*0.5];
dm25t28BassTimes = [2 2 2 2 2 2 2 2];
dm25t28Bass = makeLine(dm25t28BassTimes, dm25t28BassNotes, Guitar, 10, 0);

dm25t28 = 0.4.*dm25t28 + 2.*shuffle + 2.*dm25t28Bass;

%dm29t32
d36 = [fG fB*2 fD*2 fFs*2];
d37 = [fG fB*2 fD*2];
d38 = [fG fBb*2 fCs*2 fFs*2];
d39 = [fFs fA*2 fD*2];

dc36 = buildChord(1.4, d36, Horn, 0, 12);
dc37 = buildChord(1.4, d37, Horn, 0, 12);
dc38 = buildChord(3.5, d38, Horn, 0, 12);
dc39 = buildChord(1.5, d39, Horn, 0, 0);

dm29t32 = [dc36 rest(2.6) dc36 rest(2.6) dc36 rest(0.6) dc37 rest(0.6) dc38 1.*dc39 rest(15)];
pedal = note(2, fA*(1/4), Guitar, 10, 0) + 4.*note(2, fA*(1/8), Guitar, 10, 0);
pedal = [rest(2) pedal];
pedal = [pedal pedal pedal pedal];

dEndBassNotes = (1/8).*[fD fFs fA*2 fCs*2 fB*2 fA*2 fFs fE fD fFs fA*2 fB*2 fD*2 fD];
dEndBassTimes = [1 1 1 1 1 1 1 1 1 1 1 1 2 2];
dEndBass = makeLine(dEndBassTimes, dEndBassNotes, Guitar, 10, 0);
dm29tEndBass = [pedal dEndBass];
dm29tEnd = 0.4.*dm29t32 + 2.*dm29tEndBass + 2.*[shuffle rest(16)] + 0.1.*[rest(16) rideM3];

drum1 = 1.*[1 2 2 (1+54/80) 1 (26/80)];
drumN1 = 0.1.*drumLine(drum1, Snare);
drumN1 = [drumN1 drumN1];

songA = [m1t4 m5t8 m9t12 m13t16 m17t20 m21t24 m25t28 m29t32] + 5.*counterLine;
songD = [dm1t4 dm5t8 dm9t12 dm13t16] + 0.*dm1t16Counter;
songD = [songD dm17t20 dm21t24 dm25t28 dm29tEnd];
song = [0.5.*intro songA dintro songD];
s = slideNote(fCs, fAs, 1, 1, Clarinet);
song = song ./ max(abs(song));

%uncomment this command to play the song when matlab is run

%soundsc(song);

%uncomment these lines to write the song vector into a .wav file with name 'Mr-Sandman.wav'

% filename = 'Mr-Sandman.wav';
% audiowrite(filename, song, fs);
% clear y fs;

%This function returns a note created by taking the sine of the time vector
%multiplied and added to a few other parameters. Duration is the number of
%quarter notes that the note is held for. Pitch is the frequency of the
%note, instrument is an array of relative amplitude of the ith harmonic of
%the instrument passed in. Decay determines how the rate of exponential
%decay of amplitude (0 for no decay), and vibrato determines the rate of
%vibrato (0 for no vibrato) and amplitude tremolo.
function y = note(duration, pitch, instrument, decay, vibrato)
    vector = timeVector(duration);
    y = sin(2.*pi.*(pitch+(exp(-10.*vector).*1.5.*sin(vibrato.*pi.*vector))).*vector+0.*sin(vibrato.*pi.*vector));
    y = harmonics(instrument, duration, pitch, vibrato, y);
    y = amplitude(y, decay, vibrato, duration);
end

%returns the sum of all harmonics h of the paramater instrument, which is
%an array of relative amplitudes. The harmonics are added to the input note
%x (which is the fundamental) in the function, and have all the same parameters to the fundamental other than pitch.
function h = harmonics(instrument, duration, pitch, vibrato, x)
    vector = timeVector(duration);
    h = x;
    for i = 1:length(instrument)
        h = h + instrument(i).*sin(2.*pi.*(pitch+(exp(-10.*vector).*1.5.*sin(vibrato.*pi.*vector))).*(i+1).*vector+0.*sin(vibrato.*pi.*vector)+(0*i*pi));
    end
end

%This function creates the time vector that is used to make arrays
%throughout the code. The length is determined by taking the length_value
%parameter and multiplying it by the global variable QNL (Quarter Note
%Length). This allowed me to change tempo very easily since it is
%determined by one constant, and would have also allowed me to change tempo
%in the middle of the song
function vector = timeVector(length_value)
    global fs;
    global QNL;
    length = length_value * QNL;
    vector = [0 : 1/fs : length - 1/fs];
end

%This function multiplies an input note x by and amplitude array, which is
%used to create exponential decay and/or tremolo, called vibrato here
%because I use it in conjunction with frequency modulation vibrato to create a 
%more realistic vibrato sound
function y = amplitude(x, decayRate, vibrato, length)
    vector = timeVector(length);
    amp = adsrAmp(length);
    y = amp.*exp(-vector*decayRate).*(0.5.*sin(vibrato.*pi.*vector)+1).*x;
    %concatenate different decay functions and dot multiply by signal
end

%Returns a chord, which is multiple notes added together. Each note in the
%chord has the same decay, vibrato and instrument. This function was used
%to create most of the melody, since it is written as a four-part harmony.
function chord = buildChord(duration, pitches, instrument, decay, vibrato)
    chord = 0;
    for i = 1:length(pitches)
        chord = chord + note(duration, pitches(i), instrument, decay, vibrato);
    end
end

%Returns a note with amplitude 0 to create a rest of time duration
function rest = rest(duration)
    rest = 0.*note(duration, 440, [0], 0, 0);
end

%This function is one of the main functions used in the code. It takes in
%arrays that contains frequencies and durations, so that a melodic line can
%be created that contains the specified note parameters (intrument, decay,
%vibrato). This saves a lot of time because entire phrases can be coded
%with just two arrays which are passed into this function.
function line = makeLine(durations, pitches, instrument, decay, vibrato)
    line = 0;
    if (pitches(1) == 0)
        line = rest(durations(1));
    else
        line = note(durations(1), pitches(1), instrument, decay, vibrato);
    end
    for i = 2:length(durations)
        x = 0;
        if (pitches(i) == 0)
            x = rest(durations(i));
        else
            x = note(durations(i), pitches(i), instrument, decay, vibrato);
        end
        line = [line x];
    end
end

%This function was used to create the introduction, where notes are added
%on top of each other until a full chord is built. It takes in the space
%between each note added, the successive pitches to be added, and the total
%time the note should be held, as well as the parameters needed to create
%each note (instrument, vibrato).
function y = rollChord(space, pitches, instrument, totalTime, vibrato)
    y = rest(totalTime);
    currentBeat = 0;
    for i = 1:length(pitches)
        x = [rest(currentBeat) note(totalTime - currentBeat, pitches(i), instrument, 0, 0)];
        y = y + x;
        currentBeat = currentBeat + space;
    end
    y = amplitude(y, 0, vibrato, totalTime);
end

%This function returns an array of relative amplitudes for the first 20
%harmonics of a sawtooth wave. Not used in the code.
function y = sawtooth()
    y = -1*0.5;
    for i = 3:20
        y = [y (1/(i))*realpow(-1,i+1)];
    end
    y = y / max(abs(y));
end

%Returns a note that slides from frequency f1 to f2
%and then stays at f2 after slideTime has passed
function y = slide(f1, f2, duration, slideTime)
    global QNL;
    timeFull = timeVector(duration);
    timeSlide = timeVector(slideTime);
    timeRem = timeVector(duration-slideTime);
    freq1 = f1+(f2-f1)/(slideTime*QNL).*timeSlide;
    freq2 = f2+0.*timeRem;
    freq = [freq1 freq2];
    adsr = adsrAmp(duration);
    y = adsr.*sin(2.*pi.*(freq).*timeFull);
end

%Returns a note which contains all the harmonics at their relative amplitudes
%instrument is an array of relative amplitudes. This function is necessary
%so that all the harmonics of an note slide from f1 to f2, not just the
%fundamental frequency
function h = slideHarmonics(f1, f2, duration, slideTime, instrument)
    h = 0;
    for i = 1:length(instrument)
        h = h + instrument(i).*slide(f1*i, f2*i, duration, slideTime);
    end 
end

%Returns a note with harmonics that slide from frequency f1 to f2
%Calls slideHarmonics() to add all the harmonics of the input instrument
function y = slideNote(f1, f2, duration, slideTime, instrument)
    y = slide(f1, f2, duration, slideTime);
    h = slideHarmonics(f1, f2, duration, slideTime, instrument);
    y = y+h;
end

%This function is not used in the code, but it was used to test
%the effects of amplitude and frequency modulation.
function y = note2(d, freq)
    time = timeVector(d);
    y = sin(2.*pi.*(freq).*time);
    y2 = sin(2.*pi.*(freq).*time + 2.*exp(-time.*0).*sin(10.*pi.*time));
    y3 = exp(-time*4).*sin(5.*pi.*(freq).*time);
    y = exp(-time*1).*(0.5.*sin(10.*pi.*time)+1).*y2;
end

%adsr is an array of amplitudes that prevents the note from clipping
%at the beginning and end of the note, by starting at 0, increasing to 
%a sustain volume, and then decaying to 0 at the end of the note
%The return value adsr is multiplied by each note in the note() function
function adsr = adsrAmp(duration)
    global QNL;
    aP = 0.02; %attack/ decay time
    sV = 0.8; %sustain volume
    sP = 0.98; %sustain proportion
    pV = 0.8; %peak volume
    A = timeVector(aP*duration).*(pV/(aP*duration*QNL));
    D = timeVector(aP*duration).*((sV-pV)/(duration*aP*QNL))+pV;
    S = 0.*timeVector((sP-2*aP)*duration)+sV;
    R =(-1*sV/((1-sP)*duration*QNL)).*timeVector((1-sP)*duration)+sV;
    adsr = [A D S R];
end

%Creates a drum note. istrument is an array that contains a low and
%high frequency, as well as decay, which determines the range from which
%random frequencies will be sampled to create random noise that resembles
%the range of a snare drum, bass drum, and ride cymbol.
function y = noise(duration, instrument)
    vector = timeVector(duration);
    numValues = 500;
    y = 0;
    rng(0,'twister');
    a = instrument(1);
    b = instrument(2);
    decay = instrument(3);
    r = (b-a).*rand(numValues,1) + a;
    for i = 1:numValues
        y = y + adsrAmp(duration).*exp(-1*decay.*vector).*sin((2*pi*r(i)).*vector); %  note(duration, r(i), [0], 40, 0);
    end
end

%Takes in an array of durations 
%and the instrument, which determines the frequency
%of the noise and amount of exponential decay to
%create a percussion line
%the choices of instrument are snare drum, ride cymbol
%and bass drum
function y = drumLine(durations, instrument)
    y = noise(durations(1), instrument);
    for i = 2:length(durations)
        y = [y noise(durations(i), instrument)];
    end
end

%Creates an amplitude array which is multiplied by a note
%when it is called. Creates the effect of a crescendo
%by changing amplitude linearly from the start volume to 
%the end volume
function y = cresc(duration, startVol, endVol)
    global QNL;
    time = timeVector(duration);
    y = startVol + (endVol-startVol)/(duration*QNL) * time;
end
