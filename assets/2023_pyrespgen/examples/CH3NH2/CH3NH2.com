%chk=CH3NH2_b3lyp_a2z_esp
%nproc=28
%mem=28GB
#b3lyp/aug-cc-pvdz
#SCF=tight
#maxdisk=200GB
#Pop=MK iop(6/33=2) iop(6/42=6) iop(6/43=20)
#IOP(5/87=12)
#density=current

   B2 MP2/6-311++G(d,p) coordinates

  0                     1
  C       -0.708095503398       -0.000000893539        0.017712823484
  H       -1.112963870065       -0.880513863166       -0.486271271246
  H       -1.074379816824       -0.000087389127        1.053630363354
  H       -1.112943454187        0.880611141673       -0.486114099690
  N        0.750287956697       -0.000000780330       -0.122136797163
  H        1.148419546341        0.813654667261        0.333717877871
  H        1.148424918244       -0.813653733099        0.333717768949


