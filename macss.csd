﻿<CsoundSynthesizer>
<CsOptions>
-o dac4 -b 512 -B 512  ;'dac4' may have to be replaced with 'dac1'/'dac2'/... (check console output when Csound starts)
</CsOptions>
<CsInstruments>

sr      = 44100
ksmps   = 100
nchnls  = 2
0dbfs   = 1

#define port # 8000 #

gibufsize    =         512
gidel        =         (ksmps < gibufsize ? gibufsize + ksmps : gibufsize)/sr
gitimeout    init      1.0
gireverb     init      0.008
gireldur     init      0.03
giri         init      0.00003 * ksmps
givi         init      0.00015 * ksmps
gipi         init      0.00003 * ksmps
gici         init      0.00003 * ksmps
gili         init      0.00003 * ksmps
gihi         init      0.00003 * ksmps
gibeat       init      0
gibeats      init      0

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


opcode scaleval, i, iiiii
ip4, ivari, ip, istep, ix xin
iy                        tab_i      ip * 2, (300 + ix) * 10 + ivari
iz                        tab_i      ip * 2 + 1, (300 + ix) * 10 + ivari
                          if         (iy > 0) then
ivari                     tab_i      iz * 3, 500
imix                      tab_i      iz * 3 + 1 + ivari, 500
iv1                       tab_i      istep - 1, (300 + iz) * 10 + ivari * 2
                          if         (imix > 0) then
iv2                       tab_i      istep - 1, (300 + iz) * 10 + ivari * 2 + 1
                          else
iv2                       =          iv1
                          endif
                          else
iv1                       =          iz
iv2                       =          iz
                          endif
                          xout       (1 - i(imix)) * iv1 + i(imix) * iv2
endop

opcode scaleval2, i, iiii
ip4, ivari, ip, istep     xin
ix                        tab_i      ip4, 2030 + ivari
ivari                     tab_i      ix * 3, 500
imix                      tab_i      ix * 3 + 1 + ivari, 500
iv1                       scaleval   ip4, ivari * 2, ip, istep, ix
                          if         (imix > 0) then
iv2                       scaleval   ip4, ivari * 2 + 1, ip, istep, ix
                          else
iv2                       =          iv1
                          endif
                          xout       (1 - i(imix)) * iv1 + i(imix) * iv2
endop

opcode stepval, i, iii
iz, ivari, ip5            xin
ilen                      =          ftlen((300 + iz) * 10 + ivari)
istep                     tab_i      (ip5 % ilen), (300 + iz) * 10 + ivari
                          xout       istep
endop

opcode mod3, i, iii
ip4, ip, istep            xin
ivari                     tab_i      9, 600
imix                      tab_i      10 + ivari, 600
iv1                       scaleval2  ip4, ivari * 2, ip, istep
                          if         (imix > 0) then
iv2                       scaleval2  ip4, ivari * 2 + 1, ip, istep
                          else
iv2                       =          iv1
                          endif
iv                        =          (1 - i(imix)) * iv1 + i(imix) * iv2
                          finish:
                          xout       iv
endop

opcode seqval, i, iiiiii
ip4, ip5, ivari, ip, iss, ix xin
iy                           tab_i      ip * 4 + iss * 2, (300 + ix) * 10 + ivari
iz                           tab_i      ip * 4 + iss * 2 + 1, (300 + ix) * 10 + ivari
                             if         (iy > 0) then
ivari                        tab_i      iz * 3, 500
imix                         tab_i      iz * 3 + 1 + ivari, 500
istep                        stepval    iz, ivari * 2, ip5
iv1                          mod3       ip4, ip, istep
                             if         (imix > 0) then
istep                        stepval    iz, ivari * 2 + 1, ip5
iv2                          mod3       ip4, ip, istep
                             else
iv2                          =          iv1
                             endif
                             else
iv1                          mod3       ip4, ip, iz
iv2                          mod3       ip4, ip, iz
                             endif
                             xout       (1 - i(imix)) * iv1 + i(imix) * iv2
endop

opcode seqval2, i, iiiii
ip4, ip5, ivari, ip, iss     xin
ix                           tab_i      ip4, 2020 + ivari
ivari                        tab_i      ix * 3, 500
imix                         tab_i      ix * 3 + 1 + ivari, 500
iv1                          seqval     ip4, ip5, ivari * 2, ip, iss, ix
                             if         (imix > 0) then
iv2                          seqval     ip4, ip5, ivari * 2 + 1, ip, iss, ix
                             else
iv2                          =          iv1
                             endif
                             xout       (1 - i(imix)) * iv1 + i(imix) * iv2
endop

opcode mod2, i, iiii
ip4, ip5, ip, iss  xin
ivari              tab_i      6, 600
imix               tab_i      7 + ivari, 600
iv1                seqval2    ip4, ip5, ivari * 2, ip, iss
                   if         (imix > 0) then
iv2                seqval2    ip4, ip5, ivari * 2 + 1, ip, iss
                   else
iv2                =          iv1
                   endif
iv                 =          (1 - i(imix)) * iv1 + i(imix) * iv2
                   xout       iv
endop

opcode pval, ii, iii
ip4, ip5, ip  xin
istatic       mod2       ip4, ip5, ip, 0
islide        mod2       ip4, ip5, ip, 1
              xout       istatic, islide
endop

instr 2
iv, iv2          pval          p4, p5, 0
ir, ir2          pval          p4, p5, 1
is, is2          pval          p4, p5, 2
io, io2          pval          p4, p5, 3
ip, ip2          pval          p4, p5, 4
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
ihandle      OSCinit         $port
Sparams      init            ""
             nxtmsg:
kparams      OSClisten       ihandle, "/macss/params", "s", Sparams
             if              (kparams == 0) goto finish
             scoreline       Sparams, 1
             kgoto           nxtmsg
             finish:
endin

instr looper
             loop:
ivari        tab_i         3, 600
imix         tab_i         4 + ivari, 600
itable       =             2010 + ivari * 2
ivoices      =             ftlen(itable) - 2
itempo       tab_i         0, itable
ibeats       tab_i         1, itable
             if            (imix > 0) then
itable2      =             2010 + ivari * 2 + 1
itempo2      tab_i         0, itable2
ibeats2      tab_i         1, itable2
itempo       =             (1 - i(imix)) * itempo + i(imix) * itempo2
ibeats       =             (1 - i(imix)) * ibeats + i(imix) * ibeats2
             endif
gibeats      =             ibeats
gitimeout    =             60.0 / itempo
ibeat        =             gibeat % gibeats
gibeat       =             gibeat + 1
             timout        0, gitimeout, play
             reinit        loop
             play:
ij           =             0
             jloop:
             if            (ivoices > 0) then
idivs        tab_i         2 + ij, itable
             if            (imix > 0) then
idivs2       tab_i         2 + ij, itable2
idivs        =             (1 - i(imix)) * idivs + i(imix) * idivs2
             endif
idur         =             gibeats / idivs
ik           =             0
             kloop:
             if            (((ik * idur) >= ibeat) && ((ik * idur) < (ibeat + 1))) then
             event_i       "i", 2 + (100 + ij) * 0.001, (ik * idur - ibeat) * gitimeout, -1, ij, ik, idur * gitimeout
             endif
ik           =             ik + 1
             cigoto        ik < idivs, kloop
             else
             scoreline_i   "i -3.100 0 -1\ni -3.101 0 -1\ni -3.102 0 -1\ni -3.103 0 -1\n"
             scoreline_i   "i -3.104 0 -1\ni -3.105 0 -1\ni -3.106 0 -1\ni -3.107 0 -1\n"
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
               outs           asl, asr
endin

</CsInstruments>
<CsScore>
f 2010 0 -2 -2 200 1
f 600 0 -6 -2 0 0 0 0 0 0
e 10000000
</CsScore>
</CsoundSynthesizer>
