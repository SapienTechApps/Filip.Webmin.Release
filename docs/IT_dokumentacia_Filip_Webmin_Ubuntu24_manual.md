# IT DOKUMENTÁCIA

# INŠTALÁCIA WEBMIN CEZ FILIP.WEBMIN

Ubuntu Server 24.04 LTS – interný/testovací server

| Položka | Hodnota |
| --- | --- |
| Organizácia | [doplniť názov organizácie] |
| Systém | Webmin správa servera cez Filip.Webmin installer helper |
| Cieľové prostredie | Ubuntu Server 24.04 LTS / interná VM / testovací alebo schválený server |
| Verzia dokumentu | 1.00 |
| Posledná aktualizácia | 29.06.2026 |
| Vlastník dokumentu | [doplniť] |
| Aplikácia | Filip.Webmin |
| Release | v0.1.0 |
| GitHub | https://github.com/SapienTechApps/Filip.Webmin |

## Bezpečnostná poznámka

Dokument neobsahuje reálne heslá, tokeny, privátne kľúče ani interné tajomstvá. Všetky hodnoty v hranatých zátvorkách treba pred vykonaním nahradiť reálnymi hodnotami zo schválenej evidencie. Heslá nepísať do dokumentu ani do shell histórie.

---

# EVIDENCIA DOKUMENTU

| Položka | Hodnota |
| --- | --- |
| Účel | Krokový manuál pre stiahnutie a použitie release binárky Filip.Webmin na Ubuntu 24.04 serveri a pre bezpečné nasadenie Webminu. |
| Stav | Runbook pre lab/test a kontrolované interné nasadenie. Flow bol overený na testovacom Ubuntu 24.04.1 VM. |
| Zvolený variant | Release binárka `filip-webmin-linux-x86_64` z GitHub Releases. |
| Rozsah | Precheck, nastavenie Webmin APT repozitára, inštalácia Webminu, overenie, základné zabezpečenie, poznámky ku certifikátu. |
| Mimo rozsah | Verejné vystavenie Webminu do internetu, centrálna správa certifikátov, AD/LDAP, produkčný hardening na úrovni enterprise, automatizovaný remote deployment. |

## Dôležité rozhodnutie

Filip.Webmin v release `v0.1.0` nie je generický shell runner. Obsahuje iba pevne definované kroky:

- read-only precheck,
- review-only install plán,
- gated nastavenie Webmin APT repozitára,
- gated lokálnu inštaláciu Webminu cez fixné `apt-get` príkazy,
- export reportu.

Mutačné kroky sa nespustia bez explicitných flagov a majú sa spúšťať lokálne na cieľovom serveri cez `sudo`.

---

# OBSAH

1. Riešená problematika
2. Rozhodnutie a rozsah
3. Prerekvizity
4. Stiahnutie aplikácie Filip.Webmin
5. Procesný postup inštalácie
6. Zabezpečenie servera a Webminu
7. HTTPS certifikát a prístup cez prehliadač
8. Aktualizácie a prevádzková údržba
9. Monitoring, logy a diagnostika
10. Riešenie problémov
11. Kontrolný checklist
12. Phase Decision Log
13. Použité odkazy

---

# 1 RIEŠENÁ PROBLEMATIKA

Cieľom je nainštalovať Webmin na Ubuntu Server 24.04 LTS tak, aby bol postup auditovateľný, opakovateľný a aby sa pred mutačnými krokmi najprv vykonal read-only precheck.

Webmin je administrátorské webové rozhranie na správu Linux servera. Preto sa má používať iba v internom/serverovom segmente alebo cez VPN/management sieť. Neodporúča sa vystavovať Webmin priamo do internetu.

## Bezpečnostný rozsah

- Webmin povoľovať iba z management siete alebo VPN.
- Nepoužívať na verejnom internete bez samostatného firewall/reverse-proxy/TLS návrhu.
- Nepísať heslá do dokumentácie.
- Po inštalácii zapnúť primerané obmedzenie prístupu, aktualizácie a monitoring.
- Certifikát riešiť podľa interného PKI alebo samostatne schváleného postupu.

---

# 2 ROZHODNUTIE A ROZSAH

| Položka | Rozhodnutie |
| --- | --- |
| OS | Ubuntu Server 24.04 LTS |
| Installer helper | Filip.Webmin `v0.1.0` |
| Webmin repozitár | Nový Webmin stable repo endpoint `download/newkey/repository` |
| Inštalácia Webminu | Cez `apt-get` po schválenom repo setup kroku |
| Primárne použitie | Interná administrácia servera |
| Verejné vystavenie | Mimo rozsah tohto manuálu |

## Čo Filip.Webmin robí

- Zistí OS, architektúru, stav balíka Webmin, službu, port, firewall evidence a URL kandidátov.
- Zobrazí stav cez status indikátory `[OK]`, `[WARN]`, `[BLOCKED]`, `[UNKNOWN]`.
- Vie exportovať Markdown report.
- Vie bezpečne nastaviť Webmin APT repo cez fixný repozitár a keyring.
- Vie spustiť fixné install kroky.

## Čo Filip.Webmin nerobí

- Nie je univerzálny shell runner.
- Neprijíma vlastné príkazy od používateľa.
- Nerobí remote deployment.
- Nepracuje s heslami ani tokenmi.
- Nemení firewall pravidlá.
- Nerieši vlastný TLS certifikát automaticky.

---

# 3 PREREKVIZITY

| Položka | Odporúčanie |
| --- | --- |
| VM/server | Ubuntu Server 24.04 LTS |
| CPU | min. 2 vCPU |
| RAM | min. 2 GB; odporúčané 4 GB+ |
| Disk | min. 30 GB; podľa účelu viac |
| Sieť | interný/serverový segment, ideálne za firewallom |
| IP adresa | statická alebo DHCP rezervácia |
| DNS meno | napr. `[WEBMIN_FQDN]` |
| Admin účet | lokálny sudo používateľ |
| Internet | server musí vedieť sťahovať z GitHubu a Webmin repozitára |
| Prístup | SSH z management siete |

## Kontrolný bod pred začiatkom

- ☐ Je pripravený čistý Ubuntu Server 24.04 LTS.
- ☐ Je známa IP adresa a DNS meno servera.
- ☐ Je dostupný SSH prístup cez sudo používateľa.
- ☐ Je jasné, či ide o lab/test alebo interné nasadenie.
- ☐ Je rozhodnuté, z ktorej siete bude Webmin dostupný.
- ☐ Heslá sú uložené v KeePass alebo schválenej evidencii, nie v dokumente.

---

# 4 STIAHNUTIE APLIKÁCIE FILIP.WEBMIN

Release stránka:

```text
https://github.com/SapienTechApps/Filip.Webmin/releases/tag/v0.1.0
```

Na serveri:

```bash
mkdir -p ~/filip-webmin-release
cd ~/filip-webmin-release

curl -L -o filip-webmin \
  https://github.com/SapienTechApps/Filip.Webmin/releases/download/v0.1.0/filip-webmin-linux-x86_64

curl -L -o filip-webmin-linux-x86_64.sha256 \
  https://github.com/SapienTechApps/Filip.Webmin/releases/download/v0.1.0/filip-webmin-linux-x86_64.sha256

chmod +x filip-webmin
```

## Overenie checksumu

Checksum súbor očakáva názov `filip-webmin-linux-x86_64`. Ak bola binárka uložená ako `filip-webmin`, overiť takto:

```bash
cp filip-webmin filip-webmin-linux-x86_64
sha256sum -c filip-webmin-linux-x86_64.sha256
rm filip-webmin-linux-x86_64
```

Očakávaný výsledok:

```text
filip-webmin-linux-x86_64: OK
```

## Overenie verzie

```bash
./filip-webmin --version
```

Očakávaný výsledok:

```text
filip-webmin 0.1.0
```

---

# 5 PROCESNÝ POSTUP INŠTALÁCIE

Postup je rozdelený na precheck, repository setup, install a overenie.

## 5.1 Precheck pred inštaláciou

```bash
cd ~/filip-webmin-release
./filip-webmin
```

Očakávaný stav na čistom Ubuntu serveri:

```text
[OK] OS: Ubuntu 24.04.x LTS
[OK] Architecture: amd64/x86_64
[WARN] Package: not installed
[WARN] Decision: review required
```

Ak je OS unsupported alebo package state unknown, neinštalovať a najprv vyriešiť dôvod.

## 5.2 Export predinštalačného reportu

```bash
./filip-webmin --export filip-webmin-before-install.md
```

Report uchovať ako audit dôkaz.

## 5.3 Nastavenie Webmin APT repozitára

Tento krok je mutačný. Spúšťa sa cez `sudo` a nastaví Webmin APT source a keyring.

```bash
sudo ./filip-webmin --setup-webmin-repo --i-understand-this-mutates-system --confirm-webmin-repo-setup
```

Čo tento krok robí:

- stiahne signing key ako dáta:

```text
https://download.webmin.com/developers-key.asc
```

- vytvorí keyring:

```text
/usr/share/keyrings/webmin.gpg
```

- zapíše APT source:

```text
/etc/apt/sources.list.d/webmin.list
```

s obsahom:

```text
deb [signed-by=/usr/share/keyrings/webmin.gpg] https://download.webmin.com/download/newkey/repository stable contrib
```

## 5.4 Inštalácia Webminu

Tento krok je mutačný. Spúšťa fixné príkazy:

```text
apt-get update
apt-get install --yes webmin
```

Spustenie:

```bash
sudo ./filip-webmin --install --i-understand-this-mutates-system --confirm-install-webmin
```

Ak inštalácia prebehne úspešne, aplikácia vypíše:

```text
Phase 4 install execution completed. Re-run filip-webmin for read-only verification.
```

## 5.5 Overenie po inštalácii

```bash
./filip-webmin
```

Očakávaný stav:

```text
[OK] Package: installed
Version: 2.651 alebo novšia
[OK] Service: active
[OK] Enabled: enabled
[OK] Decision: already installed
```

## 5.6 Export poinštalačného reportu

```bash
./filip-webmin --export filip-webmin-after-install.md
```

Report uložiť ako audit dôkaz.

## 5.7 Otvorenie Webmin UI

V prehliadači:

```text
https://[SERVER_IP]:10000/
```

alebo:

```text
https://[WEBMIN_FQDN]:10000/
```

Pri self-signed certifikáte prehliadač zobrazí varovanie. To je pri internom testovacom certifikáte očakávané.

---

# 6 ZABEZPEČENIE SERVERA A WEBMINU

## 6.1 Sieťový prístup

Odporúčanie:

- Webmin port `10000/tcp` povoliť iba z management siete alebo VPN.
- Nepovoľovať port `10000` z internetu.
- SSH povoľovať iba z management siete.
- Ak sa používa OPNsense/firewall, obmedziť prístup na konkrétne admin IP rozsahy.

Príklad UFW pravidiel treba upraviť podľa siete:

```bash
sudo apt-get install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from [MGMT_CIDR] to any port 22 proto tcp
sudo ufw allow from [MGMT_CIDR] to any port 10000 proto tcp
sudo ufw enable
sudo ufw status verbose
```

## 6.2 Admin účty

- Používať samostatný admin účet, nie bežný používateľský účet.
- Heslá ukladať iba do schválenej evidencie.
- Zvážiť SSH kľúče a obmedzenie password loginu po overení prístupu.
- Vo Webmine povoliť len účty, ktoré sú skutočne potrebné.

## 6.3 Aktualizácie

Webmin aktualizovať cez APT po kontrole zmien:

```bash
sudo apt-get update
apt list --upgradable | grep -i webmin || true
sudo apt-get upgrade
```

Pre server pravidelne vykonávať:

```bash
sudo apt-get update
sudo apt-get upgrade
```

## 6.4 Fail2ban / brute-force ochrana

Pre SSH odporúčané:

```bash
sudo apt-get install -y fail2ban
sudo systemctl enable --now fail2ban
sudo fail2ban-client status
```

Webmin má vlastné bezpečnostné nastavenia a logy. Fail2ban pre Webmin dopĺňať až po overení konkrétnej log cesty a testovaní, nie naslepo.

## 6.5 Backup pred väčšími zmenami

Pred zmenami na produkčnom serveri:

- urobiť VM checkpoint alebo backup podľa interného štandardu,
- overiť, že sa dá obnoviť prístup k serveru,
- mať mimo VM uložený postup obnovy.

---

# 7 HTTPS CERTIFIKÁT A PRÍSTUP CEZ PREHLIADAČ

## Aktuálny stav

Tento manuál nerieši automatizované nasadenie vlastného certifikátu vo Filip.Webmin. Webmin po inštalácii typicky používa vlastný/self-signed certifikát, preto prehliadač zobrazí varovanie.

## Odporúčané varianty

### Variant A – interný self-signed certifikát

Vhodné pre lab a krátkodobý test. Prehliadač bude zobrazovať varovanie.

### Variant B – certifikát z internej CA

Odporúčané pre interné produkčné použitie. Postup závisí od internej PKI a zatiaľ nie je automatizovaný touto aplikáciou.

Všeobecný princíp:

- vytvoriť certifikát pre `[WEBMIN_FQDN]`,
- privátny kľúč uložiť bezpečne na server,
- nakonfigurovať Webmin `miniserv.conf` podľa oficiálnej Webmin dokumentácie,
- reštartovať Webmin službu,
- overiť v prehliadači aj cez `openssl s_client`.

### Variant C – Let’s Encrypt / verejný certifikát

Použiť iba ak je schválené verejné DNS/firewall/reverse proxy riešenie. Verejné vystavenie Webminu priamo na internet sa neodporúča.

## Kontrolný bod k certifikátu

- ☐ Je rozhodnuté, či stačí self-signed certifikát alebo treba internú CA.
- ☐ Webmin FQDN je pripravený v DNS.
- ☐ Privátny kľúč sa neukladá do repozitára ani dokumentácie.
- ☐ Certifikát má správny CN/SAN pre používané DNS meno.

---

# 8 AKTUALIZÁCIE A PREVÁDZKOVÁ ÚDRŽBA

## Kontrola stavu aplikáciou Filip.Webmin

```bash
cd ~/filip-webmin-release
./filip-webmin
./filip-webmin --export filip-webmin-periodic-check.md
```

## Kontrola Webmin služby

```bash
systemctl is-active webmin
systemctl is-enabled webmin
ss -ltn | grep ':10000' || true
```

## APT aktualizácie

```bash
sudo apt-get update
sudo apt-get upgrade
```

Po aktualizácii Webminu overiť:

```bash
./filip-webmin
```

---

# 9 MONITORING, LOGY A DIAGNOSTIKA

Základné kontroly:

```bash
./filip-webmin
systemctl status webmin --no-pager
journalctl -u webmin -n 100 --no-pager
ss -ltn
sudo ufw status verbose
```

Webmin UI:

```text
https://[SERVER_IP]:10000/
```

Kontroly v monitoringu:

- dostupnosť TCP portu 10000 z management siete,
- stav služby `webmin`,
- voľné miesto na disku,
- dostupnosť servera cez ICMP/agent podľa interného štandardu,
- neúspešné prihlasovania podľa logov.

---

# 10 RIEŠENIE PROBLÉMOV

## `decision: refused`

Chýba niektorý potvrdzovací flag. Použiť presný príkaz podľa kapitoly 5.

## `apt-get install --yes webmin` zlyhá

Najprv overiť repo setup:

```bash
cat /etc/apt/sources.list.d/webmin.list
ls -l /usr/share/keyrings/webmin.gpg
sudo apt-get update
apt-cache policy webmin
```

Potom znova:

```bash
sudo ./filip-webmin --install --i-understand-this-mutates-system --confirm-install-webmin
```

## Webmin UI nejde otvoriť

```bash
./filip-webmin
systemctl status webmin --no-pager
ss -ltn | grep ':10000' || true
sudo ufw status verbose
```

Overiť, či firewall povoľuje port `10000/tcp` z management siete.

## Prehliadač hlási nezabezpečené spojenie

Pri self-signed certifikáte je to očakávané. Pre interné produkčné použitie pripraviť certifikát z internej CA alebo samostatný TLS postup.

## Webmin hlási starý repozitár

Spustiť aktuálnu release binárku `v0.1.0` a repo setup:

```bash
sudo ./filip-webmin --setup-webmin-repo --i-understand-this-mutates-system --confirm-webmin-repo-setup
sudo apt-get update
```

Repo má smerovať na:

```text
https://download.webmin.com/download/newkey/repository stable contrib
```

---

# 11 KONTROLNÝ CHECKLIST

| OK | Kontrolný bod |
| --- | --- |
| ☐ | Ubuntu Server 24.04 LTS je nainštalovaný. |
| ☐ | Server má IP adresu a DNS meno podľa plánu. |
| ☐ | SSH prístup funguje iba zo schválenej siete. |
| ☐ | Filip.Webmin release binárka bola stiahnutá z GitHub Releases. |
| ☐ | Checksum binárky bol overený. |
| ☐ | `./filip-webmin --version` ukazuje očakávanú verziu. |
| ☐ | Predinštalačný precheck bol vykonaný. |
| ☐ | Predinštalačný report bol exportovaný. |
| ☐ | Webmin repo setup prebehol úspešne. |
| ☐ | Webmin install prebehol úspešne. |
| ☐ | Poinštalačný precheck ukazuje package installed. |
| ☐ | Webmin služba je active/enabled. |
| ☐ | Webmin UI je dostupné iba zo schválenej siete. |
| ☐ | Firewall pravidlá sú nastavené podľa management siete. |
| ☐ | Certifikátový variant je rozhodnutý a zapísaný. |
| ☐ | Heslá nie sú uložené v dokumentácii ani repozitári. |
| ☐ | Audit reporty sú uložené v dokumentácii alebo ticket systéme. |

---

# 12 PHASE DECISION LOG

| Fáza | Stav |
| --- | --- |
| Phase 2 | Read-only runtime precheck/discovery implementovaný. |
| Phase 3 | Review-only install plan implementovaný. |
| Phase 4 | Gated local install executor implementovaný. |
| Phase 5 | Gated Webmin APT repository setup implementovaný. |
| Release | `v0.1.0` dostupný na GitHub Releases. |

## Go/No-Go

GO pre lab a kontrolované interné nasadenie na Ubuntu 24.04 LTS.

NO-GO pre verejné vystavenie Webminu do internetu bez samostatného bezpečnostného návrhu, firewall pravidiel, TLS rozhodnutia a monitoringu.

---

# 13 POUŽITÉ ODKAZY

- Filip.Webmin GitHub: https://github.com/SapienTechApps/Filip.Webmin
- Filip.Webmin v0.1.0 release: https://github.com/SapienTechApps/Filip.Webmin/releases/tag/v0.1.0
- Webmin: https://webmin.com/
- Webmin downloads/repository: https://download.webmin.com/
- Ubuntu Server documentation: https://documentation.ubuntu.com/server/
- UFW documentation: https://help.ubuntu.com/community/UFW
