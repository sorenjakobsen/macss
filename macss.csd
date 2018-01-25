<CsoundSynthesizer>
<CsOptions>
-o dac4 -b 512 -B 512  ;'dac4' may have to be replaced with 'dac1'/'dac2'/... (check console output when Csound starts)
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 100
nchnls = 2
0dbfs = 1

#define port # 8000 #

gibufsize    =         512
gidel        =         (ksmps < gibufsize ? gibufsize + ksmps : gibufsize)/sr

gitimeout    init      1.0

gireverb     init      0.007

gireldur     init      0.03
gistacc      init      0.08

giri         init      0.00003 * ksmps
givi         init      0.00015 * ksmps
gipi         init      0.00003 * ksmps
gici         init      0.00003 * ksmps
gili         init      0.00003 * ksmps
gihi         init      0.00003 * ksmps

gispack      init      0
gibeat       init      0
gibeats      init      0

gkrhythm     init      16
gkorc1       init      1
gkorc2       init      1
gkmix1       init      16
gkmix2       init      16

gkshift      init      0
gkpadx       init      0.0
gkpady       init      0.0

alwayson "keysense"
alwayson "looper"
alwayson "oscreceiver"
alwayson "reverb"
alwayson "clean"
alwayson "master"

connect 3, "cleanl", "clean", "inl"
connect 3, "cleanr", "clean", "inr"
connect 3, "reverbl", "reverb", "inl"
connect 3, "reverbr", "reverb", "inr"

connect "clean", "outl", "master", "inl"
connect "clean", "outr", "master", "inr"
connect "reverb", "outl", "master", "inl"
connect "reverb", "outr", "master", "inr"

opcode stepval, i, iiiii
ip4, imix, ip, istep, ij xin
iv                       =          -1
ilen                     ftlen      3000 + imix * 10 + ip4
                         cigoto     ij >= ilen, finish
isa                      tab_i      ij, 3000 + imix * 10 + ip4
is1                      tab_i      ip * 2, 600 + isa
                         cigoto     is1 = -1 && ij != 0, finish
is1static                tab_i      ip * 2 + 1, 600 + isa
                         if         (is1static = 1) then
iv                       =          is1
                         else
                         if         (is1 = -1) then
iv                       =          0.5
                         else
iv                       tab_i      istep - 1, 700 + is1
                         endif
                         endif
                         finish:
                         xout       iv
endop

opcode patval, i, iiiiii
ip4, ip5, iorc, ip, iss, ii  xin
iv                           =          -1
ilen                         ftlen      1000 + iorc * 10 + ip4
                             cigoto     ii >= ilen, finish
ipa                          tab_i      ii, 1000 + iorc * 10 + ip4
ip1                          tab_i      ip * 2 + iss, 400 + ipa
                             cigoto     ip1 = -1 && ii != 0, finish
                             if         (ip1 = -1) then
istep                        =          5
                             else
iii                          =          int(gibeat / i(gibeats))
ilen1                        tab_i      0, 500 + ip1
ipatnum                      =          5000 + ip1 * 10 + (iii % ilen1)
ilen2                        ftlen      ipatnum
istep                        tab_i      (ip5 % ilen2), ipatnum
                             endif
ij                           =          0
                             loop:
iv1                          stepval    ip4, i(gkmix1), ip, istep, ij
ivv1                         =          iv1 = -1 ? ivv1 : iv1
iv2                          stepval    ip4, i(gkmix2), ip, istep, ij
ivv2                         =          iv2 = -1 ? ivv2 : iv2
ij                           =          ij + 1
                             cigoto     ij < 4, loop
iv                           =          (1 - i(gkpady)) * ivv1 + i(gkpady) * ivv2
                             finish:
                             xout       iv
endop

opcode modval, i, iiii
ip4, ip5, ip, iss  xin
ii                 =          0
                   loop:
iv1                patval     ip4, ip5, i(gkorc1), ip, iss, ii
ivv1               =          iv1 = -1 ? ivv1 : iv1
iv2                patval     ip4, ip5, i(gkorc2), ip, iss, ii
ivv2               =          iv2 = -1 ? ivv2 : iv2
ii                 =          ii + 1
                   cigoto     ii < 4, loop
iv                 =          (1 - i(gkpadx)) * ivv1 + i(gkpadx) * ivv2
                   xout       iv
endop

opcode modval2, ii, iii
ip4, ip5, ip  xin
istatic       modval     ip4, ip5, ip, 0
islide        modval     ip4, ip5, ip, 1
              xout       istatic, islide
endop

instr 2
is, is2          modval2       p4, p5, 0
ir, ir2          modval2       p4, p5, 1
iv, iv2          modval2       p4, p5, 2
io, io2          modval2       p4, p5, 3
ip, ip2          modval2       p4, p5, 4
ic, ic2          modval2       p4, p5, 5
il, il2          modval2       p4, p5, 6
ih, ih2          modval2       p4, p5, 7
iison            =             int(p4)
io               =             i(gitimeout) * io

                 cigoto        iv < 0.1, paramchange
ilen             tab_i         0, 20000 + (gispack * 100) + p4
                 cigoto        ilen == 0, finish
is               =             (20000 + (gispack * 100) + p4) * 10 + floor (is * 0.999 * ilen)
                 igoto         trigger
                 goto          finish
                 trigger:
                 event_i       "i", -(p1+1), io, -1
                 event_i       "i", p1+1, io, -1, is, ir, ir2, iv, iv2, ip, ip2, ic, ic2, il, il2, ih, ih2
                 goto          finish
                 paramchange:
                 event_i       "i", p1+1, io, -1, -1, -1, ir2, -1, iv2, -1, ip2, -1, ic2, -1, il2, -1, ih2
                 finish:
endin

instr 3
             xtratim     gireldur
krel         release
             if          (krel == 1) then
aenv         linseg      1, gireldur, 0
             endif
             tigoto      tie
aenv         init        1
is           init        p4
krate        init        p5
kv           init        p7
kp           init        p9
kc           init        p11
kl           init        p13
kh           init        p15
             tie:
krate        =           p6 > krate + giri ? krate + giri : (p6 < krate - giri ? krate - giri : p6)
kv           =           p8 > kv + givi ? kv + givi : (p8 < kv - givi ? kv - givi : p8)
kp           =           p10 > kp + gipi ? kp + gipi : (p10 < kp - gipi ? kp - gipi : p10)
kc           =           p12 > kc + gici ? kc + gici : (p12 < kc - gici ? kc - gici : p12)
kl           =           p14 > kl + gili ? kl + gili : (p14 < kl - gili ? kl - gili : p14)
kh           =           p16 > kh + gihi ? kh + gihi : (p16 < kh - gihi ? kh - gihi : p16)
av           interp      kv, 0, 1
kpl          =           cos(kp * $M_PI_2)
kpr          =           sin(kp * $M_PI_2)
apl          interp      kpl, 0, 1
apr          interp      kpr, 0, 1
kll          =           pow(2, kl * (10 + 1)) * 10
khh          =           pow(2, kh * (10 + 1)) * 10
             tigoto      output
             if          (is != -1) then
al, ar       loscil3     av, pow(2, (krate - 0.5) * 2), is, 1
             endif
all          tone        al, kll
alr          tone        ar, kll
ahl          atone       al, khh
ahr          atone       ar, khh
al           =           all + ahl
ar           =           alr + ahr
al           =           al * aenv * apl
ar           =           ar * aenv * apr
             output:
             outleta     "cleanl", al
             outleta     "cleanr", ar
             outleta     "reverbl", al
             outleta     "reverbr", ar
             finish:
endin

instr oscreceiver
ihandle                    OSCinit         $port
Sscore                     init            ""
kindex                     init            0
Sparams                    init            ""
kpadx                      init            0
kpady                      init            0
kshifton                   init            0
                           nxtmsg:
kparams                    OSClisten       ihandle, "/macss/params", "s", Sparams
kpad                       OSClisten       ihandle, "/macss/xy", "ff", kpadx, kpady
kshift                     OSClisten       ihandle, "/macss/shift", "f", kshifton
                           if              (kparams == 0 && kpad == 0 && kshift == 0) goto finish
                           if              (kparams != 0) then
                           scoreline       Sparams, 1
                           endif
                           if              (kpad != 0) then
gkpadx                     port            kpadx, 0.01
gkpady                     port            kpady, 0.01
                           endif
                           if              (kshift != 0) then
gkshift                    =               kshifton
                           endif
                           kgoto           nxtmsg
                           finish:
endin

instr keysense
k1         sensekey
           ckgoto    (k1 < 97 || k1 > 122), continue1
klen       tab       k1 - 97, 300
           ckgoto    klen < 1, finish
           if        (gkshift < 1) then
gkmix1     =         k1 - 97
           else
gkmix2     =         k1 - 97
           endif
           continue1:
           ckgoto    (k1 < 48 || k1 > 57), continue2
klen       tab       k1 - 48, 100
           ckgoto    klen < 1, finish
           if        (gkshift < 1) then
gkorc1     =         k1 - 48
           else
gkorc2     =         k1 - 48
           endif
           continue2:
           ckgoto    (k1 < 65 || k1 > 90), finish
klen       tab       k1 - 65, 800
           ckgoto    klen < 1, finish
gkrhythm   =         k1 - 65
           finish:
endin

instr looper
             loop:
ivoices      tab_i         i(gkrhythm), 800
             cigoto        ivoices < 1, finish
itempo       tab_i         0, 800 + i(gkrhythm)
gibeats      tab_i         1, 800 + i(gkrhythm)
gispack      tab_i         2, 800 + i(gkrhythm)
gitimeout    =             60.0 / itempo
ibeat        =             gibeat % gibeats
gibeat       =             gibeat + 1
             timout        0, gitimeout, play
             reinit        loop
             play:
ij           =             0
             jloop:
idivs        tab_i         3 + ij, 800 + i(gkrhythm)
             if            (idivs != -1) then
idur         =             gibeats / idivs
ik           =             0
             kloop:
             if            (((ik * idur) >= ibeat) && ((ik * idur) < (ibeat + 1))) then
             event_i       "i", 2 + (100 + ij) * 0.001, (ik * idur - ibeat) * gitimeout, -1, ij, ik
             endif
ik           =             ik + 1
             cigoto        ik < idivs, kloop
             endif
ij           =             ij + 1
             cigoto        ij < ivoices, jloop
             finish:
endin

instr clean
al           inleta      "inl"
ar           inleta      "inr"
al           delay       al, gidel
ar           delay       ar, gidel
             outleta     "outl", al
             outleta     "outr", ar
endin

instr reverb
al           inleta      "inl"
ar           inleta      "inr"
awl1, awr1   pconvolve   0.5 * al * gireverb, "ir.wav", gibufsize
awl2, awr2   pconvolve   0.5 * ar * gireverb, "ir.wav", gibufsize
             outleta     "outl", awl1 + awl2
             outleta     "outr", awr1 + awr2
endin

instr master
al             inleta         "inl"
ar             inleta         "inr"
asl            =              al * 0.015625
asr            =              ar * 0.015625
kthresh        =              -90
kloknee        =              -40   ;half of range 0 - 0.015625 (range is halved for every 6 db)
khiknee        =              -40
kratio         =              7     ;limit range to 0 - 0.015625
katt           =              0.01
krel           =              0.5
ilook          =              0.5
asl            compress2      asl, asl, kthresh, kloknee, khiknee, kratio, katt, krel, ilook
asr            compress2      asr, asr, kthresh, kloknee, khiknee, kratio, katt, krel, ilook
asl            =              asl * 64  ;(64 * 0.015625 = 1.0)
asr            =              asr * 64
               outs asl, asr
endin


</CsInstruments>
<CsScore>
f 100 0 -10 -2 0 0 0 0 0 0 0 0 0 0
f 300 0 -26 -2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
f 800 0 -26 -2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
e 10000000
</CsScore>
</CsoundSynthesizer>
