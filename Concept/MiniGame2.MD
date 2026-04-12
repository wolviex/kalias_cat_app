Focusing on Robot Cat allows us to integrate logical thinking, pattern recognition, and basic sequencing (the foundation of coding) in a fun, non-intimidating way.

---

### Minigame Storyboard 2: "Robot Cat’s Logic Loop"
**Focus:** Logical Thinking / Sequencing / Pattern Recognition
**Characters:** Kalia (Player Control) and Robot Cat
**Target Difficulty:** Navigator (Ages 5-6) - Adjustments for other tiers are noted.

| Panel | Scene / Visual Description | Action / Interaction (Player & UI) | Dialogue / Audio |
| :--- | :--- | :--- | :--- |
| **1: Setup** | **Scene:** A futuristic-looking console area in Robot Cat’s corner of the room. Robot Cat is standing next to a deactivated console panel. Above Robot Cat, a "status bubble" shows a broken gear icon (meaning something is broken or offline). Kalia is nearby.<br><br>**Visuals:** Clean, digital aesthetic. Cool colors (blues, purples). | **Action:** The player moves Kalia closer to Robot Cat and the console. | **SFX:** Low, rhythmic, electronic hum. The BGM has a slight techno beat.<br><br>**Robot Cat:** "Greetings, [Username]! BEEP-BOOP. The Power Grid is offline. Logic error detected." |
| **2: Trigger** | **Scene:** A large, inviting "Tap to Fix" prompt appears over the console. Kalia gestures toward the console.<br><br>**Visuals:** Dialogue bubble from Kalia with a lightbulb icon. | **Action:** The user (Player) taps the console panel. | **SFX:** A small electronic 'fizz' as the prompt is tapped.<br><br>**Kalia:** "Let’s help Robot Cat fix the power!" |
| **3: Transition** | **Scene:** The main game screen fades. We enter the dedicated 'Logic Loop' minigame overlay. The environment is now a close-up of the console panel. Kalia and Robot Cat are now small sprites on the side. A grid pattern with different colored, glowing wires is visible. | **Action:** Automatic transition. | **SFX:** A digital 'power up' swell. The BGM shifts slightly to be more focused.<br><br>**Robot Cat:** "Accessing Logic Interface... Initialize sequencing sequence." |
| **4: The Puzzle** | **Scene:** **(The core interaction).** On the grid, there is a clear start point (a glowing green energy source) and an end point (a large, greyed-out gear).<br><br>The player is presented with a 3-step sequence pattern on the side:<br>1. **Yellow Square** (Light)<br>2. **Blue Triangle** (Water)<br>3. **Yellow Square** (Light) | **Action:** The player is given a 'spare parts' inventory below the sequence, containing multiple Yellow Squares, Blue Triangles, and other distractors (like a Red Circle). | **Kalia:** "We need to complete the pattern to turn the power back on!"<br><br>**SFX:** A distinct sound for each shape selected (e.g., Yellow Square = higher chime, Blue Triangle = lower swell). |
| **5: Interaction** | **Scene:** The player drags the correct sequence into the empty slots in the power grid. As each shape is placed correctly, it "locks in" with a light effect, and a connecting wire glows. | **Action:** The player must drag and drop:<br>1. Yellow Square into slot 1.<br>2. Blue Triangle into slot 2.<br>3. Yellow Square into slot 3. | **SFX:** Successful placement 'clicks.'<br><br>**Kalia:** (After the first correct placement) "That's it! Keep the pattern going!"<br><br>**Robot Cat:** (When the pattern is half done) "Progress: 50%... Continue sequence." |
| **6: Failure State** | **Scene:** *If the player drags the Red Circle (incorrect)* into a slot. The shape wiggles and turns slightly grey. The next slot does not unlock. The prompt visually flashes "Try Again!" (or a simple emoji for younger tiers). | **Action:** The player must drag the Red Circle back to the inventory or tap the correct shape. | **Kalia:** "Hmm, that shape doesn't fit the pattern. Let's try another one!"<br><br>**SFX:** A gentle, low 'buzz' sound. (No loud or harsh failure sounds). |
| **7: Success & Reward** | **Scene:** The full 3-step sequence is complete. A surge of glowing light travels along the wires. The large gear at the end point spins wildly and glows bright green. Robot Cat spins 360 degrees and emits confetti.<br><br>Back in the living room, the console is glowing. The broken gear bubble over Robot Cat is gone. A "Logic Spark" item (collectible) appears. | **Action:** Automatic return to normal gameplay after a brief delay. The player taps the Logic Spark. | **SFX:** A triumphant, digital 'power restored' sound. Robot Cat's classic cheerful 'BEEP-BOOP!'<br><br>**Kalia:** "Yay! The power is back! Great job, we solved the logic loop!" |

---

### Producer’s Note on DDA (Dynamic Difficulty Adjustment)

* **Explorer (3-4):**
    * **The Puzzle:** Simplified to a simple 2-step *alternating* pattern (e.g., Blue, Red, Blue, Red).
    * **The Inventory:** Contains *only* the correct pieces. The challenge is just recognizing that the pieces must be moved.
    * **Visuals:** Start and end points are extremely obvious, perhaps connected by a pre-drawn line that lights up.

* **Navigator (5-6):**
    * **The Sequence:** As shown above (3-step pattern, A-B-A or A-B-C).
    * **The Inventory:** Includes one distractor shape.
    * **Pacing:** Hints are given quickly (e.g., Kalia points) if the player is stuck for 10 seconds.

* **Master (7-8):**
    * **The Puzzle:** Introduces a basic coding concept. The sequence isn’t just shapes, but **commands** (e.g., "Move Up," "Move Right," "Activate"). The goal is to program Kalia to move from Point A to Point B on the grid to fix the circuit.
    * **Complexity:** The sequence can be 4-5 steps long and include obstacles.
    * **Inventory:** Contains several distractor commands and requires logical ordering.

