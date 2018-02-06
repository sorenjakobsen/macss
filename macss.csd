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

gibeat       init      0
gibeats      init      0

gkrhythm     init      16

gkfade1       init      0.0
gkfade2       init      0.0

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

opcode scaleval, i, iiii
ip4, ivari, ip, istep     xin
ix                        tab_i      ip4, 2020 + ivari
ivari                     tab_i      ix, 500
iy                        tab_i      ip * 2, (300 + ix) * 10 + ivari
iz                        tab_i      ip * 2 + 1, (300 + ix) * 10 + ivari
                          if         (iy > 0) then
ivari                     tab_i      iz, 500
iv                        tab_i      istep - 1, (300 + iz) * 10 + ivari
                          else
iv                        =          iz
                          endif
                          xout       iv
endop

opcode seqval, i, iiiii
ip4, ip5, ivari, ip, iss     xin
ix                           tab_i      ip4, 2010 + ivari
ivari                        tab_i      ix, 500
iy                           tab_i      ip * 4 + iss * 2, (300 + ix) * 10 + ivari
iz                           tab_i      ip * 4 + iss * 2 + 1, (300 + ix) * 10 + ivari
                             if         (iy > 0) then
ivari                        tab_i      iz, 500
ilen                         =          ftlen((300 + iz) * 10 + ivari)
istep                        tab_i      (ip5 % ilen), (300 + iz) * 10 + ivari
                             else
istep                        =          iz
                             endif
iv1                          scaleval   ip4, 0, ip, istep
iv2                          scaleval   ip4, 1, ip, istep
iv                           =          (1 - i(gkfade2)) * iv1 + i(gkfade2) * iv2
                             finish:
                             xout       iv
endop

opcode modval, i, iiii
ip4, ip5, ip, iss  xin
iv1                seqval     ip4, ip5, 0, ip, iss
iv2                seqval     ip4, ip5, 1, ip, iss
iv                 =          (1 - i(gkfade1)) * iv1 + i(gkfade1) * iv2
                   xout       iv
endop

opcode modval2, ii, iii
ip4, ip5, ip  xin
istatic       modval     ip4, ip5, ip, 0
islide        modval     ip4, ip5, ip, 1
              xout       istatic, islide
endop

instr 2
is, is2          modval2       p4, p5, 2; 0
ir, ir2          modval2       p4, p5, 1
iv, iv2          modval2       p4, p5, 0; 2
io, io2          modval2       p4, p5, 3
ip, ip2          modval2       p4, p5, 4
iison            =             int(p4)
io               =             (p6 - 0.001) * io
                 cigoto        iv < 0.1, paramchange
ilen             tab_i         0, 100 + p4
                 cigoto        ilen == 0, finish
is               =             (100 + p4) * 10 + floor (is * 0.999 * ilen)
                 igoto         trigger
                 goto          finish
                 trigger:
                 event_i       "i", -(p1+1), io, -1
                 event_i       "i", p1+1, io, -1, is, ir, ir2, iv, iv2, ip, ip2
                 goto          finish
                 paramchange:
                 event_i       "i", p1+1, io, -1, -1, -1, ir2, -1, iv2, -1, ip2
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
             tie:
krate        =           p6 > krate + giri ? krate + giri : (p6 < krate - giri ? krate - giri : p6)
kv           =           p8 > kv + givi ? kv + givi : (p8 < kv - givi ? kv - givi : p8)
kp           =           p10 > kp + gipi ? kp + gipi : (p10 < kp - gipi ? kp - gipi : p10)
av           interp      kv, 0, 1
kpl          =           cos(kp * $M_PI_2)
kpr          =           sin(kp * $M_PI_2)
apl          interp      kpl, 0, 1
apr          interp      kpr, 0, 1
             tigoto      output
             if          (is != -1) then
al, ar       loscil3     av, pow(2, (krate - 0.5) * 2), is, 1
             endif
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
kval                       init            0
                           nxtmsg:
kparams                    OSClisten       ihandle, "/macss/params", "s", Sparams
kctrl                      OSClisten       ihandle, "/macss/control", "if", kindex, kval
                           if              (kparams == 0 && kctrl == 0) goto finish
                           if              (kparams != 0) then
                           scoreline       Sparams, 1
                           endif
                           if              (kctrl != 0) then
                           if (kindex == 1) then
gkfade2                    =               kval
                           else
gkfade1                    =               kval
                           endif
                           endif
                           kgoto           nxtmsg
                           finish:
endin

instr looper
             loop:
ivari        tab_i         26, 500
itable       =             2000 + ivari
ivoices      =             ftlen(itable) - 2
             cigoto        ivoices < 1, finish
itempo       tab_i         0, itable
gibeats      tab_i         1, itable
gitimeout    =             60.0 / itempo
ibeat        =             gibeat % gibeats
gibeat       =             gibeat + 1
             timout        0, gitimeout, play
             reinit        loop
             play:
ij           =             0
             jloop:
idivs        tab_i         2 + ij, itable
idur         =             gibeats / idivs
ik           =             0
             kloop:
             if            (((ik * idur) >= ibeat) && ((ik * idur) < (ibeat + 1))) then
             event_i       "i", 2 + (100 + ij) * 0.001, (ik * idur - ibeat) * gitimeout, -1, ij, ik, idur * gitimeout
             endif
ik           =             ik + 1
             cigoto        ik < idivs, kloop
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
f 2000 0 -2 -2 100 1
f 500 0 -27 -2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
e 10000000
</CsScore>
</CsoundSynthesizer>
