WT-Healthmon – Screen Layout (TunnelOps)

Top row (logical monitor numbers)
+-----+-----+-----+-----+---------+-----+-----+
|  1  |  6  |  5  |  4  |  2 / 9  |  3  |  7  |
+-----+-----+-----+-----+---------+-----+-----+
|
v
+-----+
|  8  |
+-----+

Per monitor content:

1: Blank
2: Streamlit – WT Working Section Time Clock
URL: http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock

3: Streamlit – ATR view
URL: http://streamlit-atf.dev-aero.factory.wf1/ATR?period=2025-6&token=

4: AXIS Camera Station Pro
Connected to server WT-CAMS01, running ATF healthmon view

5: WT Health Monitor application
Path: C:\Health Monitor 4.8.6 (Dev)\WilliamsF1.WindTunnel.HealthMonitor.Host.exe

6: Streamlit – Auto_QA
URL: http://streamlit-atf.dev-aero.factory.wf1/Auto_QA

7: ATF Plant Overview
URL: http://10.100.3.85/ord/file:%5Epx/WilliamsF1Grove/Misc/Plant_Overview_ATF.px%7Cview:hx:HxPxView

8: Streamlit – WT Working Section Time Clock (duplicate of 2)
URL: http://streamlit-wtworkingsection.dev-aero.factory.wf1/ChangeTimeClock

9: Mirror of monitor 2 (OS-level display mirror, no additional app)