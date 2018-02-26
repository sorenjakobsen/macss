<CsoundSynthesizer>
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
gitrigval[]  init      10, 5

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


opcode varimix, ii, i
imod          xin
ivari         tab_i         imod * 3, 500
imix          tab_i         imod * 3 + 1 + ivari, 500
              xout          ivari, imix
endop

opcode stepval, i, iii
iz, ivari, ip5            xin
ilen                      =          ftlen((300 + iz) * 10 + ivari)
istep                     tab_i      (ip5 % ilen), (300 + iz) * 10 + ivari
                          xout       istep
endop

opcode scaleval, i, iiiii
ip4, ivari, ip, istep, ix xin
iy                        tab_i      ip * 2, (300 + ix) * 10 + ivari
iz                        tab_i      ip * 2 + 1, (300 + ix) * 10 + ivari
                          if         (iy > 0) then
ivari, imix               varimix    iz
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
iscales                   tab_i      2, 400
ix                        tab_i      ip4, (300 + iscales) * 10 + ivari
ivari, imix               varimix    ix
iv1                       scaleval   ip4, ivari * 2, ip, istep, ix
                          if         (imix > 0) then
iv2                       scaleval   ip4, ivari * 2 + 1, ip, istep, ix
                          else
iv2                       =          iv1
                          endif
                          xout       (1 - i(imix)) * iv1 + i(imix) * iv2
endop

opcode scales, i, iii
ip4, ip, istep            xin
iscales                   tab_i      2, 400
ivari, imix               varimix    iscales
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

opcode animval, i, iiiiiii
ip4, ip5, ivari, ip, iss, ix, itrig xin
iy                           tab_i      ip * 4 + iss * 2, (300 + ix) * 10 + ivari
iz                           tab_i      ip * 4 + iss * 2 + 1, (300 + ix) * 10 + ivari
                             if         (iy > 0) then
ivari, imix                  varimix    iz
istep                        stepval    iz, ivari * 2, ip5
iv1                          scales     ip4, ip, istep
                             if         (imix > 0) then
istep                        stepval    iz, ivari * 2 + 1, ip5
iv2                          scales     ip4, ip, istep
                             else
iv2                          =          iv1
                             endif
                             else
                             if         (iss == 1 && iz < 0) then
iv1                          =          gitrigval[ip4][ip]
iv2                          =          gitrigval[ip4][ip]
                             else
iv1                          scales     ip4, ip, iz
iv2                          scales     ip4, ip, iz
                             endif
                             endif
iv                           =          (1 - i(imix)) * iv1 + i(imix) * iv2
                             if         (iss == 0 && itrig == 1) then
gitrigval[ip4][ip]           =          iv
                             endif
                             xout       iv
endop

opcode animval2, i, iiiiii
ip4, ip5, ivari, ip, iss, itrig     xin
ianimation                   tab_i      1, 400
ix                           tab_i      ip4, (300 + ianimation) * 10 + ivari
ivari, imix                  varimix    ix
iv1                          animval    ip4, ip5, ivari * 2, ip, iss, ix, itrig
                             if         (imix > 0) then
iv2                          animval    ip4, ip5, ivari * 2 + 1, ip, iss, ix, itrig
                             else
iv2                          =          iv1
                             endif
                             xout       (1 - i(imix)) * iv1 + i(imix) * iv2
endop

opcode animation, i, iiiii
ip4, ip5, ip, iss, itrig  xin
ianimation         tab_i      1, 400
ivari, imix        varimix    ianimation
iv1                animval2   ip4, ip5, ivari * 2, ip, iss, itrig
                   if         (imix > 0) then
iv2                animval2   ip4, ip5, ivari * 2 + 1, ip, iss, itrig
                   else
iv2                =          iv1
                   endif
iv                 =          (1 - i(imix)) * iv1 + i(imix) * iv2
                   xout       iv
endop

opcode pval, ii, iiii
ip4, ip5, ip, itrig  xin
istatic       animation  ip4, ip5, ip, 0, itrig
islide        animation  ip4, ip5, ip, 1, itrig
              xout       istatic, islide
endop

instr 2
iloop            =             p7
ips              =             p8
iv, iv2          pval          p4, p5, 0, 0
itrig            =             (iloop == 0 && iv >= 0.1) || (iloop == 1 && ips == 2) ? 1 : 0
iv, iv2          pval          p4, p5, 0, itrig
ir, ir2          pval          p4, p5, 1, itrig
is, is2          pval          p4, p5, 2, itrig
io, io2          pval          p4, p5, 3, itrig
ip, ip2          pval          p4, p5, 4, itrig
iison            =             int(p4)
io               =             (p6 - 0.001) * io
                 cigoto        itrig == 0, paramchange
ilen             tab_i         0, 100 + p4
                 cigoto        ilen == 0, finish
is               =             (100 + p4) * 10 + floor (is * 0.999 * ilen)
                 igoto         trigger
                 goto          finish
                 trigger:
                 event_i       "i", -(p1+1), io, -1
                 event_i       "i", p1+1, io, -1, is, ir, ir2, iv, iv2, ip, ip2, iloop
                 goto          finish
                 paramchange:
                 event_i       "i", p1+1, io, -1, -1, -1, ir2, -1, iv2, -1, ip2, iloop
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
iloop        =           p11
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
al, ar       loscil3     av, pow(2, (krate - 0.5) * 2), is, 1, iloop
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
iplaystate   tab_i         0, 600
ivoices      =             0
             cggoto        iplaystate == 1, timout
imetric      tab_i         0, 400
ivari, imix  varimix       imetric
itable       =             (300 + imetric) * 10 + ivari * 2
ivoices      =             (ftlen(itable) - 2) / 2
itempo       tab_i         0, itable
ibeats       tab_i         1, itable
             if            (imix > 0) then
itable2      =             (300 + imetric) * 10 + ivari * 2 + 1
itempo2      tab_i         0, itable2
ibeats2      tab_i         1, itable2
itempo       =             (1 - i(imix)) * itempo + i(imix) * itempo2
ibeats       =             (1 - i(imix)) * ibeats + i(imix) * ibeats2
             endif
gibeats      =             ibeats
gitimeout    =             60.0 / itempo
             if            (iplaystate == 2) then
gibeat       =             0
             endif
ibeat        =             gibeat % gibeats
gibeat       =             gibeat + 1
             timout:
             timout        0, gitimeout, play
             reinit        loop
             play:
ij           =             0
             jloop:
             if            (ivoices > 0 && iplaystate > 1) then
idivs        tab_i         2 + ij * 2, itable
iloop        tab_i         2 + ij * 2 + 1, itable
             if            (imix > 0) then
idivs2       tab_i         2 + ij * 2, itable2
iloop2       tab_i         2 + ij * 2 + 1, itable2
idivs        =             (1 - i(imix)) * idivs + i(imix) * idivs2
iloop        =             iloop == 1 ? 1 : iloop2
             endif
idur         =             gibeats / idivs
ik           =             0
ips          =             iplaystate
             kloop:
             if            (((ik * idur) >= ibeat) && ((ik * idur) < (ibeat + 1))) then
             event_i       "i", 2 + (100 + ij) * 0.001, (ik * idur - ibeat) * gitimeout, -1, ij, ik, idur * gitimeout, iloop, ips
             endif
ik           =             ik + 1
ips          =             3
             cigoto        ik < idivs, kloop
             tabw_i        3, 0, 600
             endif
ij           =             ij + 1
             cigoto        ij < ivoices, jloop
             if            (iplaystate == 0) then
             tabw_i        1, 0, 600
             scoreline_i   "i -3.100 0 -1\ni -3.101 0 -1\ni -3.102 0 -1\ni -3.103 0 -1\ni -3.104 0 -1\n"
             scoreline_i   "i -3.105 0 -1\ni -3.106 0 -1\ni -3.107 0 -1\ni -3.108 0 -1\ni -3.109 0 -1\n"
             endif
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
f 600 0 -1 -2 1 ;0: stop, 1: stopped, 2:start, 3: started
e 10000000
</CsScore>
</CsoundSynthesizer>
