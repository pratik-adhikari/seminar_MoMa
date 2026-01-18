# MoMa‑LLM: Language‑Grounded Dynamic Scene Graphs for Interactive Object Search 

## Problem and Motivation

Mobile manipulation robots must execute complex tasks in homes where they are unfamiliar with the layout and the locations of objects.  Most research pairs either a classical planner with a map or trains reinforcement‑learning policies for specific tasks.  These approaches struggle when the robot must explore **unknown** spaces, open doors and drawers, and reason about semantics.  Large Language Models (LLMs) possess strong commonsense reasoning but operate over text; they have no notion of the robot’s geometry or sensor data.  How can we integrate language models with robot perception so that the robot can *plan semantically* while *grounding its actions* in the physical world?

## Method: Dynamic 3D Scene Graph + LLM Planning

MoMa‑LLM proposes to ground pre‑trained LLMs in a **dynamic scene graph (DSG)** built as the robot explores an environment【29500996880504†L5-L24】.  A dense map is converted into a Voronoi graph of navigable nodes.  A room‑segmentation module uses door detections to cluster the Voronoi graph into rooms, unlike prior systems that rely purely on geometric bottlenecks and fail in open‑concept layouts【29500996880504†L648-L668】.  Objects detected by the robot’s sensors are inserted into the DSG as nodes, and edges encode spatial relations such as “inside”, “on top of” or adjacency.  The key components are:

1. **Open‑Vocabulary Scene Representation.**  The DSG represents rooms and objects using language‑agnostic embeddings, enabling arbitrary object classes.  Room boundaries are determined by probabilistic door detection rather than narrow corridors, yielding higher segmentation precision and recall than Hydra【29500996880504†L648-L669】.

2. **Structured Knowledge Extraction.**  At each high‑level planning step, the system extracts a **compact textual summary** of the DSG.  This summary lists explored and unexplored rooms, the objects observed in each room, and “frontier” nodes representing unexplored areas.  It also encodes task history and the estimated distance of each action.  This structured prompt constrains the LLM’s output and prevents hallucinations.

3. **Object‑Centric Action Space.**  A set of primitive actions—`go_to(room/object)`, `open(container)`, `search(room)`, `inspect(object)` and `done()`—is exposed to the LLM.  The LLM reasons over the textual summary and outputs the next high‑level action.  Low‑level navigation and manipulation policies then execute the selected action, update the DSG and repeat.

4. **Evaluation Metric.**  The authors introduce an **efficiency curve** measuring the fraction of successful episodes versus the number of low‑level steps.  The area under this curve (AUC‑E) summarizes efficiency without requiring an arbitrary time budget【29500996880504†L648-L669】.

## Key Contributions

The paper lists five primary contributions【29500996880504†L96-L109】:

- **Scalable dynamic scene graph representation** with open‑vocabulary room clustering and classification.
- **Structured and compact knowledge extraction** from the DSG to ground LLMs.
- A **semantic interactive object search task** that requires combining navigation, manipulation and reasoning.
- A **new evaluation paradigm** using full efficiency curves and the AUC‑E metric.
- A **publicly available codebase** for reproducibility.

## Experiments

### Simulation

The team evaluated MoMa‑LLM on a set of eight unseen apartments in the iGibson simulator.  Each episode required finding a specified object (e.g., “find the detergent”) in a randomly initialized environment.  Performance was compared with heuristic baselines (Random, Greedy), a commonsense exploration method (ESC‑Interactive), a hierarchical RL agent (HIMOS), and an **Unstructured LLM** baseline where the LLM received only a flat list of objects without graph structure.

The results (Table I in the paper) show that MoMa‑LLM achieved the highest success rate (SR), efficiency (SPL) and AUC‑E among all methods【29500996880504†L676-L736】:

| Method | Success Rate (%) | SPL (%) | AUC‑E | Distance Travelled (m) | Infeasible Actions |
|------|-----------------|-------|------|--------------------|------------------|
| Random | 93.1 | 50.2 | 77.0 | 32.9 | – |
| Greedy | 85.7 | 50.9 | 72.9 | 22.3 | – |
| ESC‑Interactive | 95.4 | 62.7 | 84.5 | 19.6 | – |
| HIMOS (hierarchical RL) | 93.7 | 48.5 | 77.4 | 35.9 | – |
| **Unstructured LLM** | 86.3 | 59.4 | 77.6 | 18.5 | 0.41 |
| **MoMa‑LLM w/ Hydra** | 92.0 | 61.9 | 84.3 | 12.9 | 0.06 |
| **MoMa‑LLM (ours)** | **97.7** | **63.6** | **87.2** | 18.2 | 0.19 |
| w/o frontiers (ablation) | 79.4 | 55.0 | 72.2 | 15.6 | 0.91 |
| w/o history (ablation) | 94.9 | 63.0 | 84.1 | 17.1 | 0.26 |

MoMa‑LLM outperformed the unstructured LLM by over **11 percentage points** in success rate and achieved the highest efficiency.  Removing frontier information degraded performance severely (79.4 % SR), underscoring the importance of representing unexplored space【29500996880504†L676-L736】.  The Hydra variant, which uses purely geometric room segmentation, performed worse than the full system, highlighting the value of door‑based room clustering【29500996880504†L648-L669】.

### Real‑World Transfer

To test transferability, the authors deployed MoMa‑LLM on a Toyota HSR robot in a real apartment with four rooms and 54 objects.  Assumptions such as accurate semantic perception, localization and handle detection were satisfied via pre‑mapping and AR markers【29500996880504†L900-L941】.  The robot compared MoMa‑LLM with ESC on identical tasks.  Both systems succeeded in **8/10 episodes** (80 %), but MoMa‑LLM traveled roughly **17.9 m** on average versus **33.9 m** for ESC and required fewer object interactions【29500996880504†L900-L924】.  This suggests that the structured DSG and LLM reasoning lead to more targeted exploration.  The system also handled subpolicy failures (e.g., a gripper slipping) by re‑planning via dialogue【29500996880504†L946-L959】.

## Discussion

1. **Why does structure matter?**  The DSG serves as a *lingua franca* between perception and language.  Without it, the unstructured LLM baseline had a lower success rate and generated many infeasible actions, evidencing hallucinations.  Incorporating frontiers and history into the prompt allows the LLM to reason about unexplored space and avoid revisiting rooms【29500996880504†L676-L736】.

2. **Handling open‑concept layouts.**  Hydra segments rooms by detecting narrow passages, which fails when a kitchen and dining room share a wide opening.  MoMa‑LLM’s door‑based clustering yields higher precision and recall and improved graph purity because it leverages semantic cues like doors or floor transitions【29500996880504†L648-L669】.

3. **Scalability and costs.**  Building the DSG online incurs computational overhead, yet the authors show that their system runs in real time and scales to apartments with many rooms.  The evaluation metric AUC‑E avoids choosing an arbitrary time budget and provides a fair comparison across methods【29500996880504†L648-L669】.

4. **Limitations.**  MoMa‑LLM assumes access to reliable object detections and a set of low‑level policies for navigation and manipulation.  It does not explicitly incorporate motion costs into the LLM’s reasoning; the planner might ask the robot to open a far‑away drawer even if a closer search could succeed.  The system also relies on resetting the scene after each high‑level step, which could slow down in very large environments.

## Conclusion

MoMa‑LLM demonstrates that combining **dynamic scene graphs** with **structured language prompts** enables a mobile manipulation robot to perform efficient, zero‑shot object search in unfamiliar indoor environments.  By converting raw sensor data into a hierarchical, open‑vocabulary representation and extracting compact textual summaries, the system effectively grounds an LLM’s commonsense knowledge in the physical world.  Extensive simulation and real‑world experiments show that this structured grounding yields higher success rates and efficiency than existing baselines【29500996880504†L676-L736】【29500996880504†L900-L924】.  Although further work is needed to handle full cost‑aware planning and to reduce dependence on pre‑trained perception, MoMa‑LLM provides a compelling blueprint for integrating language and geometry in robot reasoning.

## TL;DR

MoMa‑LLM addresses the problem of mobile robots searching for objects in unknown homes by building a **dynamic 3D scene graph** that clusters rooms using door detections and adds nodes for detected objects.  At each planning step, the robot extracts a **compact textual summary** of this graph—including explored rooms, objects, frontiers and action costs—and feeds it to a Large Language Model.  The LLM chooses high‑level actions such as `go_to`, `open` or `search`, which low‑level controllers execute.  Experiments on eight unseen apartments and a real apartment show that MoMa‑LLM achieves higher success rates and efficiency (SPL and AUC‑E) than heuristic, RL and unstructured LLM baselines【29500996880504†L676-L736】【29500996880504†L900-L924】.  The work demonstrates that **structured scene representations are vital for grounding language in robotics** and offers a roadmap toward more general household tasks.
