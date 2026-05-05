1. **Revert User Access**
    - Instruct all users:
        - Stop using `shr-tunops-mts`
        - Log back in using:
            - `TunnelOps`
    - Confirm:
        - Users regain full operational access

------

1. **Restore Active Sessions**
    - Log out of all sessions using:
        - `shr-tunops-mts`
    - Re-establish sessions using:
        - `TunnelOps`

------

1. **Revert Services (if modified)**

    - Open:

      ```
      services.msc
      ```

    - For any services changed to `shr-tunops-mts`:

        - Revert logon account to:
            - `TunnelOps`

    - Restart services

    - Confirm:

        - Services start cleanly
        - Dependent systems function

------

1. **Revert Scheduled Tasks (if modified)**

    - Open:

      ```
      taskschd.msc
      ```

    - For any modified tasks:

        - Reset account to:
            - `TunnelOps`

    - Run tasks manually

    - Confirm:

        - Successful execution

------

1. **Validate System Operation**
    - Using `TunnelOps`, confirm:
        - RRS fully operational (M10502/M10501)
        - MMS fully operational (M10504/M10503)
        - Comms stable (W9343/W9309)
        - Temperature control functional (W9321)

------

1. **Validate OPC Recovery (CRITICAL)**
    - Launch OPC test client / TestSlate
    - Confirm:
        - Successful connections
        - Live data updates
        - No “OPC inactive” state
        - Cross-system messaging restored

------

1. **Validate Data & File Operations**
    - Confirm read/write access to:
        - `\\smb.wf1-isil01.factory.wf1\department2\ATF\03_Maintenance\Facilities\WT2\MTS`
        - Local MTS directories
    - Confirm:
        - No data loss
        - No backlog or stalled processing