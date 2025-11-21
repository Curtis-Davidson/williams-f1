# **WT2Sum Excel Add-In – Issue Summary & Resolution (Weekly Report)**



### **1. Problem Overview**



During the TunnelOps migration, the legacy **WT2Sum Excel add-in (v1.09)** failed to install on the new Windows 10/11 machines.

The error presented was:

> *“Customized functionality will not work because the certificate used to sign the deployment manifest is not trusted…”*

The add-in used **ClickOnce/VSTO** packaging from **2019**, signed with a certificate that had **expired**, and contained **broken/invalid manifest hashes**.

The installer had effectively become **unusable** on modern Windows builds.

This explains why the add-in ran on the old machines for years, but failed as soon as we moved to a clean new build.

------



### **2. Why It Was a Hard Failure**

The WT2Sum add-in contained three critical problems:

1. **Expired signing certificate** (ClickOnce requires a valid code-signing chain)

2. **Manifest files (.manifest + .vsto) contained outdated SHA1 hashes**

3. **Modern Windows 10/11 ClickOnce validation is stricter**

   – mismatched hashes → automatic installation block

   – expired certificate → immediate trust failure

The installer was never rebuilt since 2019, so it simply couldn’t pass modern validation.

This is why:

- It failed repeatedly on the new TunnelOps workstation.
- It sometimes worked on older machines where the expired certificate had previously been trusted.

------



### **3. What We Actually Had to Do (Rebuild Required)**



We ended up performing a **full repack + resign** of the add-in using Microsoft’s SDK tools.

Steps completed:

1. **Extracted** the working directory from the old backup.

2. **Generated a new PFX certificate** with a modern SHA256 profile.

3. **Exported a matching CER** and imported it into:



- LocalMachine\TrustedPublisher
- LocalMachine\Root



4. Used **signtool.exe** to re-sign the DLL.

5. Used **mage.exe** (Manifest Generation and Editing Tool) to:



- Rebuild the application manifest (.dll.manifest)
- Rebuild the deployment manifest (.vsto)
- Recompute all the hash blocks
- Apply the new certificate



6. **Verified all signatures** with PowerShell (Authenticode).

7. **Cleared ClickOnce caches** and reinstalled.

Only *after* all three components matched (DLL + manifest + VSTO) did the installer work.

This was essentially the equivalent of **recompiling the installer**, but done manually without the original Visual Studio project.



------



### **4. Why This Took Time**

Because:

- We had **no original Visual Studio project**, only the binaries.

  (This forces a full manual rebuild using mage.exe + signtool.)

- The manifests were **corrupted** due to outdated SHA1 hashing.

- Windows 11 blocks any ClickOnce deployment that isn’t perfectly signed.

- Each rebuild step had to be validated to avoid installing a broken add-in inside Excel.

- Testing on multiple machines was required because ClickOnce cache behaviour varies.

In short:

**This wasn’t “installing an add-in” — it was reconstructing a broken installer without source code.**



------



### **5. Final Result**

- WT2Sum 1.09 was **successfully repacked, re-signed, and deployed** on the new TunnelOps workstation.
- Certificate chain now **valid until 2026**.
- Installer now works reliably on **new Windows 10/11 builds**.
- This avoids a rewrite of the add-in and extends functional life of the old tool.