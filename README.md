# PowerToolkit

PowerToolkit is a collection of PowerShell scripts designed to simplify various tasks. This toolkit aims to enhance productivity by automating common operations.

## Getting Started

### Prerequisites

- Windows operating system
- PowerShell 7.4 or higher

### Installation

1. Clone the repository to your local machine:

    ```sh
    git clone https://github.com/Mulekotd/PowerToolkit.git
    ```

2. Navigate to the PowerToolkit directory:

    ```sh
    cd PowerToolkit
    ```

3. Run the `setup.ps1` script to set up the necessary environment variables and create executables:

    ```sh
    .\setup.ps1
    ```

### Modules

#### `New-Backup.psm1`

A script to create backups of files or directories.

**Parameters:**

- `-Directory` (optional): Indicates if the path is a directory. If not specified, the path is considered to be a file.
- `-Path` (mandatory): The path of the file or directory to backup.
- `-BackupLocation` (optional): The location where the backup will be stored. Default is `C:\Backups`.
- `-Help` (optional): Displays help message.

**Usage Examples:**

- To backup a directory:

    ```sh
    New-Backup -Directory -Path 'C:\MyFolder' -BackupLocation 'D:\Backups'
    ```

- To backup a file:

    ```sh
    New-Backup -Path 'C:\MyFile.txt' -BackupLocation 'D:\Backups'
    ```

### Directory Structure

```sh
C:.
│   LICENSE
│   README.md
│   setup.ps1
│   uninstall.ps1
│   update.ps1
│
└───modules
        New-Backup.psm1
```
