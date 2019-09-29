#cloud-config
system_info:
  default_user:
    name: root
manage_etc_hosts: true
disable_root: false
write_files:
  - path: /etc/update-motd.d/00-custom-msg
    permissions: "0755"
    content: |
      #!/bin/bash      
      printf "\n\n ********** Hello Assurity DevOps ********** \n\n\n"
  - path: /tmp/createUser
    permissions: "0755"
    content: |
      #!/bin/bash      
      useradd -m -d /home/ubuntu -s /bin/bash ubuntu
      usermod -aG sudo ubuntu
  - path: /etc/ssh/assurity_ca.pub
    permissions: "0644"
    content: |
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvZ6JPrSVXj6h5i4CgCcMI5VY/4cC9PbKQLpkxVZsYTLxcKz7pXGn2NNj6aZ5f4jrTarsHDw9WaSSYzek21CPhcyAWgIzx1RlMlW53InURC7JSmaRlOMvTmykCjan4ZCQwdUHQBDklg3UKM81d7s/FCyNf3/CxqTjJyurUpTVJD1pAwV1qdgakHKr3tp269DTCfdnG2vuxrvGo5otvmXzHZNP43tus+/x0eSZLGifmxipxvMweTXDXiNfUgvMF9mKnppk214OxUSKT6TQ4ScYb9ZYiMbNp4REcmQrQVtTGpoeAZuyhGlG9mJn4cuk2c86Oh1/rQ7UvAy+/RHnWvWnt ravind@Mac-RR.local
  - path: /etc/ssh/sshd_config
    permissions: "0755"
    content: |
      # Package generated configuration file
      # See the sshd_config(5) manpage for details

      # What ports, IPs and protocols we listen for
      Port 22
      # Use these options to restrict which interfaces/protocols sshd will bind to
      #ListenAddress ::
      #ListenAddress 0.0.0.0
      Protocol 2
      # HostKeys for protocol version 2
      HostKey /etc/ssh/ssh_host_rsa_key
      HostKey /etc/ssh/ssh_host_dsa_key
      HostKey /etc/ssh/ssh_host_ecdsa_key
      HostKey /etc/ssh/ssh_host_ed25519_key
      
      TrustedUserCAKeys /etc/ssh/assurity_ca.pub
      #Privilege Separation is turned on for security
      UsePrivilegeSeparation yes

      # Lifetime and size of ephemeral version 1 server key
      KeyRegenerationInterval 3600
      ServerKeyBits 1024

      # Logging
      SyslogFacility AUTH
      LogLevel INFO

      # Authentication:
      LoginGraceTime 120
      PermitRootLogin no
      StrictModes yes

      RSAAuthentication yes
      PubkeyAuthentication yes
      #AuthorizedKeysFile	%h/.ssh/authorized_keys

      # Don't read the user's ~/.rhosts and ~/.shosts files
      IgnoreRhosts yes
      # For this to work you will also need host keys in /etc/ssh_known_hosts
      RhostsRSAAuthentication no
      # similar for protocol version 2
      HostbasedAuthentication no
      # Uncomment if you don't trust ~/.ssh/known_hosts for RhostsRSAAuthentication
      #IgnoreUserKnownHosts yes

      # To enable empty passwords, change to yes (NOT RECOMMENDED)
      PermitEmptyPasswords no

      # Change to yes to enable challenge-response passwords (beware issues with
      # some PAM modules and threads)
      ChallengeResponseAuthentication no

      # Change to no to disable tunnelled clear text passwords
      PasswordAuthentication no

      # Kerberos options
      #KerberosAuthentication no
      #KerberosGetAFSToken no
      #KerberosOrLocalPasswd yes
      #KerberosTicketCleanup yes

      # GSSAPI options
      #GSSAPIAuthentication no
      #GSSAPICleanupCredentials yes

      X11Forwarding yes
      X11DisplayOffset 10
      PrintMotd no
      PrintLastLog yes
      TCPKeepAlive yes
      #UseLogin no

      #MaxStartups 10:30:60
      #Banner /etc/issue.net

      # Allow client to pass locale environment variables
      AcceptEnv LANG LC_*

      Subsystem sftp /usr/lib/openssh/sftp-server

      # Set this to 'yes' to enable PAM authentication, account processing,
      # and session processing. If this is enabled, PAM authentication will
      # be allowed through the ChallengeResponseAuthentication and
      # PasswordAuthentication.  Depending on your PAM configuration,
      # PAM authentication via ChallengeResponseAuthentication may bypass
      # the setting of "PermitRootLogin without-password".
      # If you just want the PAM account and session checks to run without
      # PAM authentication, then enable this but set PasswordAuthentication
      # and ChallengeResponseAuthentication to 'no'.
      UsePAM yes
  - path: /tmp/cleanup
    permissions: "0755"
    content: |
      #!/bin/bash      
      rm -rf createUser
runcmd:
  - bash /etc/update-motd.d/00-custom-msg
  - touch /var/lib/cloud/instance/locale-check.skip
  - ufw allow 22
  - ufw --force enable
  - bash /tmp/createUser
  - bash /tmp/cleanup
  - bash /etc/ssh/assurity_ca.pub
  - bash /etc/ssh/sshd_config
  - /etc/init.d/ssh restart