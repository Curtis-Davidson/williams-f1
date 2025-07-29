Option 1: Canon uniFLOW Job Forwarding (if using uniFLOW)
Confirm if you are using Canon uniFLOW — this supports:

"Delegated Print Access" or Job Forwarding

Allows multiple users (sub-accounts) to release jobs on behalf of the main account

How to implement:

Keep all print jobs spooling as SHR-MACHINE-MFG

Create sub-accounts:
SHR-MACHINE-MFG-1, SHR-MACHINE-MFG-2

Assign each card to a sub-account

In uniFLOW Admin Portal:

Set delegation so sub-accounts can view and release jobs queued by SHR-MACHINE-MFG

Result:
Multiple cards can authenticate independently and still see and release the same jobs — no session collisions.