module DecisionRules

using ..CoreTypes

export decision_status,
       unique_answer_result,
       equivalence_class_result,
       nonanswer_result

"""
Apply the frozen fail-closed precedence:
out of domain, insufficient observation, equivalence class, numerical
abstention, then unique answer.
"""
function decision_status(;
    in_domain::Bool,
    observation_complete::Bool,
    equivalence_size::Integer,
    numerically_resolved::Bool,
)
    equivalence_size >= 1 || throw(ArgumentError("equivalence_size must be positive"))
    !in_domain && return OutOfDomain
    !observation_complete && return InsufficientObservation
    equivalence_size > 1 && return EquivalenceClassOnly
    !numerically_resolved && return Abstain
    return Answer
end

"""Construct a checked unique-answer result."""
unique_answer_result(answer) = IdentifiabilityResult(Answer, answer, nothing)

"""Construct a checked equivalence-class-only result."""
function equivalence_class_result(class_representative; witnesses::Vector{String} = String[])
    return IdentifiabilityResult(
        EquivalenceClassOnly,
        class_representative,
        MultipleEquivalentModels,
        witnesses,
    )
end

"""Construct a checked non-answer result with explicit witnesses."""
function nonanswer_result(
    status::ResultStatus,
    reason::AbstentionReason;
    witnesses::Vector{String} = String[],
)
    status in (InsufficientObservation, Abstain, OutOfDomain) ||
        throw(ArgumentError("status is not a non-answer status"))
    return IdentifiabilityResult(status, nothing, reason, witnesses)
end

end
