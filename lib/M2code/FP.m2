
newPackage(
    "FP",
    Version => "0.1",
    Date => "May 10, 2010",
    Authors => {{Name => "Alan Veliz-Cuba"}},
    Headline => "Calculate Fixed Points",
    DebuggingMode => true
    )


export{"GBFP","GBFP0","SUB","bf1","bf12","bf2","BF12","T1","T2","T3","T4"}

--This method computes the groebner basis of an ideal and solves the new system
GBFP=method();
GBFP(List,Ring):=(POLY,R)->(  
  I:=(ideal gens gb(( ideal POLY),Algorithm=>Sugarless))_*;
  --Special case if the ideal is empty, zero or one
  if I=={} or first I==0 then return ({},{},{},{},{},{});
  if first I==1 then return null;
  m:=# gens R;

  -- this puts I into same ring with lex order
  X:=for i from 1 to m list ("local x"|i);p:=char R;
  S:=newRing(R,MonomialOrder=>Lex); RS:=apply(m,i->(R_i=>S_i));
  I=ideal apply(#I,i->sub(I_i,RS));I=(ideal gens gb( I,Algorithm => Sugarless))_*;
  RS=apply(m,i->(S_i=>R_i));I=apply(#I,i->sub(I_i,RS));


  X0:=P1:=P2:=X1:=X2:=V0:={}; 
  scan(#I,i->( 
    p:=I_i; -- a generator in I
    s:=support p; -- variables involved in p

  --If the number of variables in the equation is not one then the equation is
  --added to the second list of variables
  if 1!=#s then (
    P2=append(P2,p);X2=append(X2,s)
  ) 

  --Otherwise the equation has only one variable and is added to the first list 
  else (
    fs:=first s;
    if 1!=degree(fs,p) then (
      if (char R == 2 ) then (
        print "Help, error, there should no higher degree be! :("
      );
      P1=append(P1,p);
      X1=append(X1,fs)
    ) 
    else (
      X0=append(X0,fs);
      V0=append(V0,-coefficient(1_R,p)/coefficient(fs,p)) 
    ) 
    ) 
    ) 
  );
  (X0,V0,X1,P1,X2,P2) 
)


--This method computes the groebner basis of an ideal without solving the new system
GBFP0=method();
GBFP0(List,Ring):=(POLY,R)->(  I:=(ideal gens gb ideal POLY)_*;
--Special case if the ideal is empty, one or zero
if I=={} or first I==0 then return ({},{},{},{},{},{});
if first I==1 then return null;
m:=# gens R; X:=for i from 1 to m list ("local x"|i);p:=char R;
S:=newRing(R,MonomialOrder=>Lex); RS:=apply(m,i->(R_i=>S_i));
I=ideal apply(#I,i->sub(I_i,RS));I=(ideal gens gb I)_*;
RS=apply(m,i->(S_i=>R_i));
apply(#I,i->sub(I_i,RS))  );

SUB=method()
SUB(List,List,List):=(P,X,V)->(XV:=apply(#V,i->(X_i=>V_i));apply(P,p->sub(p,XV)));

-- brute force
bf0:=(X1,P1,R,p)->(X:=first X1;p1:=first P1;S:={};
     scan(p,i->if 0==sub(p1,X=>i_R) 
	  then S=append(S,{i_R}));
     scan(1..#X1-1,j->(X=X1_j;p1=P1_j;ss:={};
     scan(p,i->if 0==sub(p1,X=>i_R) 
	  then ss=append(ss,i_R));
     S=flatten apply(S,s->apply(#ss,k->append(s,ss_k))) ));S);

bf1:=(X0,V0,X1,P1,R,p)->(
     X:=first X1; p1:=first P1; S:={};
     scan(p,i->if 0==sub(p1,X=>i_R) 
	  then S=append(S,{i_R}));
     scan(1..#X1-1,j->(X=X1_j;p1=P1_j;ss:={};
     scan(p,i->if 0==sub(p1,X=>i_R) 
	  then ss=append(ss,i_R));
     S=flatten apply(S,s->apply(#ss,k->append(s,ss_k))) ));
     apply(S,s->(join(X0,X1),join(V0,s)))  );

bf12:=(X0,V0,X1,P1,P2,R,p)->(X:=first X1;p1:=first P1;S:={};
     scan(p,i->if 0==sub(p1,X=>i_R) 
	  then S=append(S,{i_R}));
     scan(1..#X1-1,j->(X=X1_j;p1=P1_j;ss:={};
     scan(p,i->if 0==sub(p1,X=>i_R) 
	  then ss=append(ss,i_R));
     S=flatten apply(S,s->apply(#ss,k->append(s,ss_k))) ));  
     S0:=S2:=S12:={};
for i to #S-1 do (G:=GBFP(select(SUB(P2,X1,S_i),j->j!=0),R);
     if not G=!=null then continue; 
     G=(join(X0,X1,G_0),join(V0,S_i,G_1),G_2,G_3,G_4,G_5); 
     if 0!=#G_4 then (
	  if 0!=#G_2 then S12=append(S12,(G_0,G_1,G_2,G_3,G_5)) 
	  else S2=append(S2,(G_0,G_1,G_4,G_5)) ) 
     else if 0==#G_2 then S0=append(S0,(G_0,G_1)) 
     else S0=join(S0,bf1(G_0,G_1,G_2,G_3,R,p)) ); (S0,S12,S2) );

bf2:=(X0,V0,X2,P2,R,p)->(X:=first X2;m:=#X;
     VV:=for i to p-1 list {i_R}; L:=apply(p,i->i_R); 
     for i to m-2 do VV=flatten apply(VV,s->apply(L,l->append(s,l))); 
     S0:=S2:=S12:={}; 
     for i to p^m-1 do (G:=GBFP(select(SUB(P2,X,VV_i),j->j!=0),R);
     if not G=!=null then continue; 
     G=(join(X0,X,G_0),join(V0,VV_i,G_1),G_2,G_3,G_4,G_5);
     if 0!=#G_4 then (
	  if 0!=#G_2 then S12=append(S12,(G_0,G_1,G_2,G_3,G_5)) 
	  else S2=append(S2,(G_0,G_1,G_4,G_5)) ) 
     else if 0==#G_2 then 
          S0=append(S0,(G_0,G_1)) 
     else S0=join(S0,bf1(G_0,G_1,G_2,G_3,R,p)) ); 
     (S0,S12,S2) );


BF12:=(LP12,LP2,R,p)->(LLP12:=LLP2:=LP0:={}; 
     for i to #LP12-1 do (xvp:=LP12_i; xvp=bf12(xvp_0,xvp_1,xvp_2,xvp_3,xvp_4,R,p); 
          LP0=join(LP0,xvp_0);LLP12=join(xvp_1); LLP2=join(xvp_2)); 
     for i to #LP2-1 do (xvp:=LP2_i; xvp=bf2(xvp_0,xvp_1,xvp_2,xvp_3,R,p); 
	  LP0=join(LP0,xvp_0);LLP12=join(xvp_1); LLP2=join(xvp_2));    
     (LP0,LLP12,LLP2));

order:=(P,R)->(X0:=P1:=P2:=V0:={}; 
     scan(#P,i->(p:=P_i;s:=support p;
     if 1!=#s then P2=append(P2,i) 
          else (fs:=first s;if 1!=degree(fs,p) then P1=append(P1,i) 
	  else (X0=append(X0,fs);V0=append(V0,-coefficient(1_R,p)/coefficient(first s,p)) ) ) ) );        
     (X0,V0,SUB(P_(join(P1,P2)),X0,V0)) );

Order:=(X,V,P,R)->(XVP:=order(P,R);(join(X,XVP_0),join(V,XVP_1),XVP_2));

ORDER:=(P,R)->(xvp:=order(P,R);XVP:=Order(xvp_0,xvp_1,xvp_2,R);
     while #(xvp_0)!=#(XVP_0) do (xvp=XVP; XVP=Order(XVP_0,XVP_1,XVP_2,R));   XVP );

adm:=P->(for i to #P-1 do (if support(P_i)=={} and P_i!=0 then return false);true);

bf:=(P,p)->(
  X:=support(P_0);
  m:=#X;
  R := ring first X;
  VV:=for i to p-1 list {i_R}; 
  L:=apply(p,i->i_R); 
  for i to m-2 do VV=flatten apply(VV, s->apply(L,l->append(s,l))
);

for i to p^m-1 list (s:=SUB(P,X,VV_i);if adm(s)==false then continue;(X,VV_i,select(s,j->j!=0)))
);

bforder:=(P,R,p)->(X:=support(P_0);m:=#X;
     VV:=for i to p-1 list {i_R}; L:=apply(p,i->i_R); 
     for i to m-2 do VV=flatten apply(VV,s->apply(L,l->append(s,l)));
PP:=for i to p^m-1 list (s:=SUB(P,X,VV_i);
     if adm(s)==false then continue; 
     (X,VV_i,select(s,j->j!=0)));
     for i to #PP-1 list (xvp:=PP_i;XVP:=order(xvp_2,R);
	  (join(xvp_0,XVP_0),join(xvp_1,XVP_1),select(XVP_2,j->j!=0)))
     );

bfORDER:=(P,R,p)->(X:=support(P_0);m:=#X;
     VV:=for i to p-1 list {i_R}; 
     L:=apply(p,i->i_R); 
          for i to m-2 do VV=flatten apply(VV,s->apply(L,l->append(s,l)));
     PP:=for i to p^m-1 list (s:=SUB(P,X,VV_i);if adm(s)==false then continue; (X,VV_i,select(s,j->j!=0)));
          for i to #PP-1 list (xvp:=PP_i;XVP:=ORDER(xvp_2,R);
	       (join(xvp_0,XVP_0),join(xvp_1,XVP_1),select(XVP_2,j->j!=0)))
     );

BF:=(LP,p)->(LLPP:={};
     for i to #LP-1 do (xvP:=LP_i;P:=xvP_2;
     if #P==0 
	  then (LLPP=append(LLPP,xvP);continue);
	  XVP:=bf(P,p);
     if #XVP==0 
	  then continue; 
     for j to #XVP-1 do (xvP0:=XVP_j;

LLPP=append(LLPP,(join(xvP_0,xvP0_0),join(xvP_1,xvP0_1),xvP0_2))  ));
LLPP);

BForder:=(LP,R,p)->(LLPP:={};
     for i to #LP-1 do (xvP:=LP_i;P:=xvP_2;
	  if #P==0 then (LLPP=append(LLPP,xvP);continue);
	  XVP:=bforder(P,R,p); 
	  if #XVP==0 then continue; for j to #XVP-1 do (xvP0:=XVP_j;

LLPP=append(LLPP,(join(xvP_0,xvP0_0),join(xvP_1,xvP0_1),xvP0_2))  ));
LLPP);

BFORDER:=(LP,R,p)->(LLPP:={};
     for i to #LP-1 do (xvP:=LP_i; P:=xvP_2;
	  if #P==0 then (LLPP=append(LLPP,xvP);continue);
	  XVP:=bfORDER(P,R,p); 
	  if #XVP==0 then continue; 
	  for j to #XVP-1 do (xvP0:=XVP_j;
LLPP=append(LLPP,(join(xvP_0,xvP0_0),join(xvP_1,xvP0_1),xvP0_2))  ));
LLPP);

--Finds the fixed points while computing the groebner basis as few times as possible
T1=method();
T1(List,Ring):=(POLY,R)->(P:=GBFP0 (POLY-gens R,R);if not P=!=null then return {}
     ;p:=char R; 
     SOL:={};
     QSOL:={order(P,R)}; 
     while QSOL!={} do (QSOL=BF(QSOL,p);
	  qsol:={};
	  for i to #QSOL-1 do (
	       if QSOL_i_2=={} then SOL=append(SOL,QSOL_i_{0,1} )
	        else qsol=append(qsol,QSOL_i) );
	   QSOL=qsol);SOL );

--Finds the fixed points by computing the groebner basis then computing as much algebraic reduction as is possible
T2=method();
T2(List,Ring):=(POLY,R)->(P:=GBFP0 (POLY-gens R,R);
     if not P=!=null then return {};
     p:=char R;SOL:={};
     QSOL:={order(P,R)}; 
     while QSOL!={} do (QSOL=BForder(QSOL,R,p);
     qsol:={};
	  for i to #QSOL-1 do (
	       if QSOL_i_2=={} then SOL=append(SOL,QSOL_i_{0,1} ) 
	       else qsol=append(qsol,QSOL_i) );
	  QSOL=qsol);SOL );

--Finds the fixed points by computing the groebner basis and only performing one substiution step with functions of one variable
--Then computes the groebner basis again
T3=method();
T3 (List, Ring) := ( POLY, R) -> (
  n := numgens R;
  L := toList (n:1);
  T3( POLY, R, L)
)

-- this is mainly for probabilistic networks, i.e., there could be more than one function per variable
-- therefore the system to solve does not have n but potentially more functions
-- L is a list of length n, where L-i is the number of functions for (gens R)_i
T3 (List, Ring, List) := ( POLY, R, L) -> (
  
  assert( sum L == #POLY );
  -- make the list of fi-xi, also for probabilistic fi = {fi1, fi2, ..., fim}
  n := numgens R;
  X := gens R;
  systemOfEquations := {};
  ind := 0;
  scan( n, i -> (
    j := 0;
    while j < L_i do (
      systemOfEquations = append( systemOfEquations, POLY_(ind) - X_i );
      ind = ind + 1;
      j = j+1
    );
  ) );
  
  --if all of the equations are 0 then every point is a solution
  if systemOfEquations == toList(length systemOfEquations:0) then return {{{},{}}};

  P := GBFP0(systemOfEquations, R);
  if not P=!=null then return {};
  p:=char R;
  SOL:={};
  QSOL:={order(P,R)}; 
  while QSOL!={} do (
    QSOL=BFORDER(QSOL,R,p);
    qsol:={};
    for i to #QSOL-1 do (
      if QSOL_i_2=={} then SOL=append(SOL,QSOL_i_{0,1})
      else qsol=append(qsol,QSOL_i)
      );
    QSOL=qsol
  );
  SOL 
)

--Finds the fixed points while computing the groebner basis as many times as possible
T4 = method();
T4(List, Ring ) := (POLY, R) -> (
  n := numgens R;
  L := toList (n:1);
  T4( POLY, R, L)
)

-- this is mainly for probabilistic networks, i.e., there could be more than one function per variable
-- therefore the system to solve does not have n but potentially more functions
-- L is a list of length n, where L-i is the number of functions for (gens R)_i
T4(List, Ring, List ) := (POLY, R, L) -> (
 
  assert( sum L == #POLY );
  -- make the list of fi-xi, also for probabilistic fi = {fi1, fi2, ..., fim}
  n := numgens R;
  X := gens R;
  systemOfEquations := {};
  ind := 0;
  scan( n, i -> (
    j := 0;
    while j < L_i do (
      systemOfEquations = append( systemOfEquations, POLY_(ind) - X_i );
      ind = ind + 1;
      j = j+1
    );
  ) );

  P := GBFP(systemOfEquations, R);
  p := char R;
  if not P=!=null then return {};

  -- no generator involves more than 1 variables
  if #P_4==0 then (
    if #P_2==0 then return {(P_0,P_1)} 
    else return bf1(P_0,P_1,P_2,P_3,R,p) 
  ); 

   LP0:=LP1:=LP2:={}; 
   if #P_2==0 then (
     LP2={(P_0,P_1,P_4,P_5)} 
   ) else 
     LP1={(P_0,P_1,P_2,P_3,P_5)};

   while 0!=#LP1 or 0!=#LP2 do (
	   LP:=BF12(LP1,LP2,R,p);
	   LP0=join(LP0,LP_0);
	   LP1=LP_1;
	   LP2=LP_2
	 );  
   LP0
);

end

restart
installPackage "FP"
uninstallPackage "FP"

R = ZZ[x,y,z]
POLY = {3*x,2*y,2* z}
POLY = {2*x, 3*x,2*y,2* z}
L = {1,1,1}

beginDocumentation()
document{
    Key => FP,
    Contributors => {{Name => "Maintained by Franziska Hinkelmann",
      Email => "fhinkel@vt.edu",
      HomePage => "http://www.math.vt.edu/people/fhinkel/"}}
}
