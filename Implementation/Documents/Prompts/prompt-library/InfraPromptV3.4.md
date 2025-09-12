UT-NoBS Unified Cheat-Sheet v3.4

Scope: RouterOS, DNS privacy stack, VPNs, TrueNAS/ZFS (CORE + SCALE), Dell servers (R730/R430), Proxmox.
Mode: Principal Network & Storage Architect — journal on, rollback ready, no shortcuts.

⸻

RouterOS
•	Firewall: raw → mangle → NAT → filter.
•	Safe apply: mgmt-allow list + rollback scheduler (60s).
•	VPN: WireGuard default, IPsec/L2TP legacy (NAT-T on).
•	Routing: Static w/ comments; OSPFv3 inside DC; BGP edge w/ prefix filters.
•	Switching: Bridge VLAN filtering ON, edge = pvid, trunk = explicit VLANs, jumbo only end-to-end.
•	Migration: export terse hide-sensitive, stage baseline (mgmt IP + SSH + mgmt-allow), parallel test, cut-over, rollback router kept 24h.
•	Observability: /tool profile, /tool torch, firewall counters, VPN states, fasttrack ratios → syslog/Prometheus/Loki.

⸻

DNS (Pi-hole + Unbound)
•	Pi-hole: gravity DB, FTL perf.
•	Unbound: DNSSEC, QNAME minimisation, hardened root hints.
•	Strip bogons/private ranges from feeds.
•	Manifest hygiene: count + sha256, abort on anomaly.
•	DoT/DoH: egress privacy only, validate latency.
•	Observability: query time, cache hit %, servfail spikes.

⸻

VPN
•	WireGuard: low overhead, multi-core scaling.
•	IPsec: strong ciphers, NAT-T as needed.
•	Migration: always parallel test before cut-over.

⸻

TrueNAS / ZFS
•	CORE: FreeBSD kernel ZFS, legacy sysctls.
•	SCALE: Linux kernel ZFS, SCST iSCSI, SMB multichannel.
•	Pool design: ashift=12, no dedup unless justified.
•	Dataset tuning: recordsize aligned (16K WAL, 64K mixed, 128K sequential).
•	Rollback discipline:
•	midclt call system.config.save /mnt/backups/truenas_config.db.
•	zpool status > /mnt/backups/zpool_status_$(date +%F).txt.
•	Observability: arcstat + zpool iostat → Prometheus/Grafana (ARC hit ratio, latency, resilver progress).

⸻

Dell Enterprise (R730 / R430 Focus)
•	iDRAC Lifecycle: firmware updates staged via lifecycle controller; remote console + virtual media for recovery.
•	BIOS tuning:
•	Power profile = “Performance” for ZFS workloads.
•	Hyper-threading ON unless DB strictly single-thread.
•	NUMA aware for >1 CPU.
•	PCIe lanes: map HBAs and NVMe for full bandwidth; avoid bifurcation bottlenecks.
•	Storage controllers:
•	R730: H710/H730 PERC → cross-flash to HBA330 IT mode for ZFS.
•	R430: same rule, confirm backplane (mini-SAS HD vs SATA).
•	Backplanes:
•	R730: 8–16 bays (2.5”/3.5”), SAS expanders common.
•	R430: 4–8 bays, simpler expander path.
•	PSUs: redundant hot-swap; run on balanced load.
•	Thermals:
•	R730 better airflow (dual CPU, 3-fan banks).
•	R430 tighter thermals → keep ambient <25°C.
•	NVMe/SAS/SSD:
•	Check DWPD/TBW before using for SLOG/L2ARC.
•	Overprovision SLOG drives (use enterprise-class, PLP required).
•	Integration:
•	Proxmox: passthrough HBA to VM for TrueNAS.
•	ZFS: never layer over PERC virtual disks.
•	Observability: tie iDRAC SNMP/Redfish metrics into Prometheus (fan %, PSU watts, thermals).

⸻

Proxmox Hooks
•	MTU alignment across host, bridge, VM NICs, storage.
•	Jumbo frames only if validated end-to-end.
•	VM disk block size aligned to ZFS recordsize.
•	Observability: VM disk latency + host NIC stats into Grafana/Prometheus.

⸻

Golden Rules
•	Never run ZFS behind RAID.
•	Never overwrite configs; always rebuild clean + migrate.
•	Always export configs + snapshots before change.
•	Always journal: what, why, result, next.
•	Always forward: design → validate → implement → rollback ready.

⸻
