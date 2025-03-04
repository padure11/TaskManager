# Bash Resource Management Script

Acest script Bash oferă funcționalități pentru monitorizarea resurselor de sistem, gestionarea proceselor și configurarea sistemului pe o mașină Linux. Include opțiuni pentru următoarele acțiuni:

- Monitorizarea resurselor (CPU, RAM, hard disk, rețea)
- Operarea cu procese (pornire, suspendare, terminare, etc.)
- Schimbarea configurațiilor de resurse
- Vizualizarea logurilor de sistem
- Afișarea utilizării discului pe directoare
- Vizualizarea proceselor de top în funcție de utilizarea memoriei

## Cerințe

- Sistem Linux
- Acces la sudo pentru a schimba configurări și vizualiza loguri
- Bash 4.x sau mai recent

## Instalare

1. Clonați repo-ul pe mașina dvs.:

    ```bash
    git clone https://github.com/<user>/<repository>.git
    ```

2. Navigați în directorul proiectului:

    ```bash
    cd <repository>
    ```

3. Oferiți permisiuni de execuție scriptului:

    ```bash
    chmod +x script.sh
    ```

## Utilizare

Lansați scriptul cu opțiunile dorite. Exemple de utilizare:

- **Monitorizarea resurselor:**

    ```bash
    ./script.sh -m 10s
    ```

    Aceasta va monitoriza resursele la fiecare 10 secunde.

- **Operarea cu procese:**

    ```bash
    ./script.sh -p
    ```

    Aceasta va deschide un meniu pentru a alege operațiuni pe procese (pornire, suspendare, etc.).

- **Vizualizarea top proceselor:**

    ```bash
    ./script.sh -t 5
    ```

    Afișează primele 5 procese în funcție de utilizarea memoriei.

- **Terminați un proces:**

    ```bash
    ./script.sh -k soft
    ```

    Aceasta va permite terminarea unui proces prin semnalul `SIGTERM` (soft kill).

- **Repornirea unui proces:**

    ```bash
    ./script.sh -r
    ```

    Permite repornirea unui proces specificat de utilizator prin PID.

- **Vizualizarea logurilor în timp real:**

    ```bash
    ./script.sh -l
    ```

    Aceasta va deschide logurile de sistem în timp real.

- **Vizualizarea utilizării discului:**

    ```bash
    ./script.sh -u
    ```

    Aceasta va arăta utilizarea discului pentru fiecare director.

## Opțiuni disponibile

- `-m, --monitor <interval>`: Monitorizează resursele la un interval specificat (ex. `-m 10s` pentru fiecare 10 secunde)
- `-p, --process`: Permite operarea cu procese (pornire, suspendare, mutare în background/foreground)
- `-c, --config`: Permite modificarea configurațiilor de resurse (ex. schimbarea valorii `swappiness`)
- `-t, --top <count>`: Afișează topul proceselor în funcție de utilizarea memoriei (ex. `-t 5` pentru top 5 procese)
- `-k, --kill <soft|hard>`: Permite terminarea unui proces (soft sau hard)
- `-r, --restart`: Permite repornirea unui proces prin PID
- `-l, --log`: Afișează logurile de sistem în timp real
- `-u, --usage`: Afișează utilizarea discului pe directoare
- `-h, --help`: Afișează acest mesaj de ajutor

## Note

- Este necesar să aveți permisiuni de root pentru a modifica configurațiile de sistem sau pentru a vizualiza logurile de sistem.
- Fiți atent la opțiunile care pot termina sau modifica procesele, deoarece acestea pot afecta funcționarea normală a sistemului.

## Contribuții

Dacă doriți să contribuiți la acest proiect, deschideți o cerere de tragere (pull request) cu modificările dorite.

## Licență

Acest proiect este licențiat sub Licența MIT - vezi fișierul [LICENSE](LICENSE) pentru detalii.
