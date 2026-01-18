# Seminar Report: Language-Grounded Dynamic Scene Graphs for Interactive Object Search

**Student Name:** [Your Name]  
**Date:** [Date]  
**Supervisor:** [Supervisor Name]  

## Abstract
[Write a concise summary: problem, method, key results, why it matters.]

---

## 1. Introduction
[Explain the motivation and define the task.]

**Key points to cover**
- Motivation for mobile manipulation in unexplored environments  
- Define the **Interactive Semantic Search** task (what the robot must do, under what uncertainty, and what counts as success)

---

## 2. Related Work
[Organize by themes and compare.]

### 2.1 3D Scene Graphs
- Hydra: [Summary: what it builds, how it updates, why it matters]
- Other: [Any other relevant systems]

### 2.2 LLMs for Planning
- SayPlan: [Summary: planning interface, grounding, strengths/limits]
- Other: [Similar methods]

### 2.3 Object Search
- ESC: [Summary: exploration/search baseline]
- Other: [Classic semantic search / frontier exploration / embodied AI baselines]

---

## 3. Paper Summary

### 3.1 Problem Statement
[State the problem formally and operationally.]

**POMDP formulation (write explicitly)**
- **Tuple:** \( (S, A, O, T, P, r) \)
- **S (States):** [What constitutes the world state?]
- **A (Actions):** [What actions can the agent take?]
- **O (Observations):** [What does the robot observe?]
- **T (Transition):** [How states evolve]
- **P (Observation model):** [How observations arise]
- **r (Reward):** [What is being optimized]

### 3.2 Approach: MoMa-LLM
[Give a high-level overview. Reference Fig. 2 from the paper in your write-up.]

#### 3.2.1 Hierarchical 3D Scene Graph
[Explain the hierarchy and what each layer represents.]

**Voronoi Graph Construction**
- [How nodes/edges are formed]
- [Why Voronoi helps navigation/search]

**Room Classification**
- [How the LLM is prompted]
- [What inputs it gets (text? objects? geometry?)]
- [What output labels are produced]

#### 3.2.2 High-Level Action Space
**Actions (list explicitly)**
- `Map` / `Maps`: [meaning]
- `go_to_and_open`: [meaning]
- `close`: [meaning]
- `explore`: [meaning]
- `done`: [meaning]

#### 3.2.3 Grounded High-Level Planning
[How the system turns the scene graph + language goal into actions.]

**Scene Structure Encoding**
- [How the graph is serialized into text]
- [What fields are included/excluded]

**Partial Observability**
- [How frontiers/unknown space are represented]
- [How replanning happens]

---

## 3.3 Experiments

### 3.3.1 Experimental Setup
- **Simulator:** iGibson  
- **Robot (Sim):** Fetch  
- **Robot (Real):** Toyota HSR  

### 3.3.2 Evaluation Metrics
- **Success Rate (SR):** [definition]
- **SPL:** [definition]
- **AUC-E (Area Under Efficiency Curve):**  
  [Explain what “efficiency curve” is and why AUC is informative/novel here.]

### 3.3.3 Results
**Simulation**
- MoMa-LLM vs baselines: [Key numbers + interpretation]
- Failure modes: [When it fails and why]

**Real-world Transfer**
- Transfer capabilities: [What transfers? what breaks?]
- Latency and practical constraints: [timing, sensing, actuation]

---

## 4. Discussion
**Strengths**
- Open-vocabulary reasoning
- Structured reasoning with scene graphs
- [Anything else]

**Limitations**
- Perception dependency (garbage-in/garbage-out)
- Latency (LLM calls, planning delays)
- [Anything else]

**Reproducibility**
- Code availability: [Is code released? what parts?]
- Missing details: [What is underspecified?]

---

## 5. Conclusion
[Restate problem, contribution, results, and what’s next.]

---

## References
- [Main paper citation]
- [Hydra]
- [SayPlan]
- [ESC]
- [Any other key works]
