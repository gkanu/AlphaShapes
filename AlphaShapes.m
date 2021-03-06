(* ::Package:: *)

(************************************************************************)                                               
(* This file is intended to be loaded into the Mathematica kernel using *)
(* the package loading commands Get or Needs.  Doing so is equivalent   *)
(* to using the Evaluate Initialization Cells menu command in the front *)
(* end.                                                                 *)                                                 
(************************************************************************)



(* ::Input::Initialization:: *)
BeginPackage["AlphaShapes`"]


(* ::Input::Initialization:: *)
alphaShapeMesh::usage="alphaShapeMesh[points, crit] computes the alpha shape of a given point set"
circumRadius::usage="circumRadius[n] computes the circumradius of a triangle or circumsphere of a tetrahedron"
RealQ::usage="RealQ[x] is a predicate function that gives True whenever x is a Real number and False otherwise"


(* ::Input::Initialization:: *)
alphaShapeMesh::nargs="alphaShapeMesh called with `1` argument(s); 2 expected";
alphaShapeMesh::badargs="The `1` argument of alphaShapeMesh must be a `2`";


(* ::Input::Initialization:: *)
Options[alphaShapeMesh]=Options[MeshRegion]


(* ::Input::Initialization:: *)
Begin["`Private`"]


(* ::Input::Initialization:: *)
RealQ=Internal`RealValuedNumericQ;
$symbols={alphaShapeMesh,circumRadius,RealQ};
patt={{_?RealQ,_?RealQ}..}|{{_?RealQ,_?RealQ,_?RealQ}..};


(* ::Input::Initialization:: *)
circumRadius[2]=Compile[{{v,_Real,2}},
With[{a=Norm[v[[1]]-v[[2]]],b=Norm[v[[1]]-v[[3]]],c=Norm[v[[2]]-v[[3]]]},
With[{den=(a+b+c) (b+c-a) (c+a-b) (a+b-c)},If[den==0.,$MaxMachineNumber,(a b c)/Sqrt[den]]
]
],RuntimeOptions->"Speed",RuntimeAttributes->{Listable},CompilationOptions->{"InlineExternalDefinitions"->True}]

circumRadius[3]=Compile[{{v,_Real,2}},
With[{a=v[[1]]-v[[4]],b=v[[2]]-v[[4]],c=v[[3]]-v[[4]]},
With[{a1=a[[1]]^2+a[[2]]^2+a[[3]]^2,b1=b[[1]]^2+b[[2]]^2+b[[3]]^2,c1=c[[1]]^2+c[[2]]^2+c[[3]]^2,
\[Alpha]1=b[[2]]c[[3]]-b[[3]]c[[2]],\[Alpha]2=b[[3]]c[[1]]-b[[1]]c[[3]],\[Alpha]3=b[[1]]c[[2]]-b[[2]]c[[1]],
\[Beta]1=c[[2]]a[[3]]-c[[3]]a[[2]],\[Beta]2=c[[3]]a[[1]]-c[[1]]a[[3]],\[Beta]3=c[[1]]a[[2]]-c[[2]]a[[1]],
\[Gamma]1=a[[2]]b[[3]]-a[[3]]b[[2]],\[Gamma]2=a[[3]]b[[1]]-a[[1]]b[[3]],\[Gamma]3=a[[1]]b[[2]]-a[[2]]b[[1]]},
With[{den=(2 Norm[Plus@@({a[[1]],a[[2]],a[[3]]}{\[Alpha]1,\[Alpha]2,\[Alpha]3})])},If[den==0.,$MaxMachineNumber,Norm[a1{\[Alpha]1,\[Alpha]2,\[Alpha]3}+b1 {\[Beta]1,\[Beta]2,\[Beta]3}+c1 {\[Gamma]1,\[Gamma]2,\[Gamma]3}]/den]]
]
],RuntimeOptions->"Speed",RuntimeAttributes->{Listable},CompilationOptions->{"InlineExternalDefinitions"->True}]


(* ::Input::Initialization:: *)
alphaShapeMesh[x_,Except[_?RealQ,y_],opts:OptionsPattern[]]:=(Message[alphaShapeMesh::badargs,"second","Real number"]; $Failed)
alphaShapeMesh[x_,y_?RealQ,opts:OptionsPattern[]]:=(Message[alphaShapeMesh::badargs,"first","2D or 3D array of Real numbers"]; $Failed)
alphaShapeMesh[x___]:=(Message[alphaShapeMesh::nargs,Length[{x}]]; $Failed)


(* ::Input::Initialization:: *)
alphaShapeMesh[points:patt,crit_?RealQ,opts:OptionsPattern[]]:=
Module[{alphacriteria,dim=Last@Dimensions@points,
del=Quiet@DelaunayMesh[points],polys,polycoords,polyradii,getExternalFaces},
alphacriteria[polyhedra_,radii_,rmax_]:=Pick[polyhedra,UnitStep@Subtract[rmax,radii],1];
getExternalFaces[facets_]:=If[facets=={},EmptyRegion[dim],
MeshRegion[points,facets,FilterRules[{opts},Options[alphaShapeMesh]]]];
If[Head[del]===EmptyRegion,del,
polys=MeshCells[del,dim];
polycoords=MeshPrimitives[del,dim][[All,1]];
polyradii=circumRadius[dim][polycoords];
Check[getExternalFaces@alphacriteria[polys,polyradii,crit],EmptyRegion[dim],MeshRegion::dgcell]
]
]


(* ::Input::Initialization:: *)
SetAttributes[Evaluate@$symbols,{Locked,Protected,ReadProtected}]


(* ::Input::Initialization:: *)
End[]


(* ::Input::Initialization:: *)
EndPackage[]
