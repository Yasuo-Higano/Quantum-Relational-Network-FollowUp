"""
    QRNReplication

Clean-room Julia implementations used to test the claims catalogued in
`docs/claim_inventory.md`. Public APIs carry observation and result semantics
explicitly; no module imports original QRN implementation artifacts.
"""
module QRNReplication

include("CoreTypes.jl")
include("States/FermionFock.jl")
include("Responses/LocalResponse.jl")
include("Responses/ManyBodyResponse.jl")
include("Factorization/OperationAlgebra.jl")
include("Hypergraphs/SupportDecomposition.jl")
include("Geometry/GraphGeometry.jl")
include("Homology/SimplicialHomology.jl")
include("Identifiability/DecisionRules.jl")
include("Anomalies/AnomalyChecks.jl")
include("LatticeFermions/FluxDiagnostics.jl")
include("LatticeFermions/BWNormalization.jl")
include("Generators/AdversarialCases.jl")
include("Scoring/SelectiveScoring.jl")
include("Reproducibility/ExperimentIO.jl")

using .CoreTypes
using .FermionFock
using .LocalResponse
using .ManyBodyResponse
using .OperationAlgebra
using .SupportDecomposition
using .GraphGeometry
using .SimplicialHomology
using .DecisionRules
using .AnomalyChecks
using .FluxDiagnostics
using .BWNormalization
using .AdversarialCases
using .SelectiveScoring
using .ExperimentIO

export CoreTypes,
       FermionFock,
       LocalResponse,
       ManyBodyResponse,
       OperationAlgebra,
       SupportDecomposition,
       GraphGeometry,
       SimplicialHomology,
       DecisionRules,
       AnomalyChecks,
       FluxDiagnostics,
       BWNormalization,
       AdversarialCases,
       SelectiveScoring,
       ExperimentIO

end
