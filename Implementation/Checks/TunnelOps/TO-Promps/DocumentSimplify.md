Perfect — I understand exactly what you’re after. You’ve got a BA-authored discovery document (for TunnelOps) that’s cluttered with bureaucratic filler, excessive references, and governance language. You want to strip all that away and extract only the practical working intelligence:
what machines, what accounts, what apps, what actions, and how it’s expected to be implemented — in your consistent, no-BS Williams Formula One style.

Before I build the refined extraction prompt, I need to confirm a few key things so it can be bullet-proof and reusable across all TunnelOps sequences (and other departments later).

Confirm these points
1.	Input format:
The BA docs — are they inside the ZIP as .docx, .pdf, or .xlsx? (I’ll unpack and inspect, but want to be sure which type the extractor should target.)
2.	Output structure (per sequence):
You said each sequence will produce:
•	CAB Document (for approval submission)
•	Support Document (for IT/service desk reference)
•	Working Document (for actual implementation tasks)
•	Summary Overview (one-page at-a-glance)
Confirm if you want all four emitted in a single Markdown file with four headings, or four separate .md files (e.g. SEQ11_CAB.md, SEQ11_Support.md, etc.).
3.	Consistent implementation model:
•	Shared account logon restriction → via User Object → Logon To → specific machine (no group complexity)
•	RDP access → via OU = Shared Accounts RDP, machine group per machine, users added to that group, group added locally to Remote Desktop Users
Confirm that this logic must be auto-inserted as the standard method every time RDP or logon restrictions are mentioned.
4.	Naming flexibility:
Keep the BA’s naming unless the department requests a tweak to final descriptor — confirm this should be noted as:
“Final naming to be confirmed with department for contextual clarity.”
5.	Tone:
Friendly, cooperative, practical. No governance wording, no corporate filler, no “refer to section x.y”. Just readable, factual, and ready to act on.
6.	Markdown style:
Do you want fenced code blocks (```powershell etc.) for commands, or plain indented lists for action steps?

Once confirmed, I’ll generate the Reusable Extraction Prompt that you’ll use each time you upload a BA doc. It will:
•	auto-strip irrelevant filler
•	extract machines, accounts, users, and software
•	identify dependencies (apps, logins, Intune, etc.)
•	build the 4 clean Markdown outputs automatically
•	embed your standard implementation methods where applicable.
