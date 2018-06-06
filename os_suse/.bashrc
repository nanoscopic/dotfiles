# Colorize ls and use long list format 
alias ll='ls -l'
alias ls='ls --color'

# Handy shortcuts for zypper
alias zy='zypper'
alias zyp='zy se --provides'
alias zyi='sudo zypper in'

# Alias to set the window title - TTOP is topic, WINTITLEU is the machine name
alias rtitle='echo -en "\033];$TTOP$WINTITLEU\a"'
# Easier to type path to root, automatically setting window title
alias sup='sudo su -; rtitle'

# Setup virsh so that the user can access the system qemu
export VIRSH_DEFAULT_CONNECT_URI="qemu:///system"

# Point kubectl to use a downloaded kubeconfig from Kubic velum
export KUBECONFIG=~/Downloads/kubeconfig

# Change the prompt
export PS1="\w\n$ "

# Set the window title ( customize with your preferred default ssh tab title )
export WINTITLEU="user @ Laptop"

# Set the window title to the just set default
rtitle

# Functions for ssh and su that also set window title
function ssh() { /usr/bin/ssh "$@"; rtitle; }
function su()  { /usr/bin/su  "$@"; rtitle; }

# Function to set window title directly
function topic() { export TTOP="$@ - "; rtitle; }

# Function to easily ssh into the various nodes of a default Kubic devenv
function cssh() {
  case $* in
    a|admin*     ) echo -en "\033];caasp-admin\a"   ; ssh root@10.17.1.0; rtitle; ;;
    m|m0|master* ) echo -en "\033];caasp-master-0\a"; ssh root@10.17.2.0; rtitle; ;;
    w0|worker0*  ) echo -en "\033];caasp-worker-0\a"; ssh root@10.17.3.0; rtitle; ;;
    w1|worker1*  ) echo -en "\033];caasp-worker-1\a"; ssh root@10.17.3.1; rtitle; ;;
    my|mysql     ) echo -en "\033];mysql\a";
      ssh -t root@10.17.1.0 'docker exec -it \
        $(docker ps -f name=mariadb --format="{{.ID}}") \
        mysql -u velum -D velum_production --password=$(cat /var/lib/misc/infra-secrets/mariadb-velum-password)'; ;;
    *) echo 'a | m | w0 | w1'; ;;
  esac
}

# Function to easily start and stop services with less typing
function sc() {
  case $* in
    d* ) shift 1; echo "Stopping $@"; sudo systemctl stop "$@" ;;
    u* ) shift 1; echo "Starting $@"; sudo systemctl start "$@" ;;
    r* ) shift 1; echo "Restarting $@"; sudo systemctl restart "$@" ;;
    s* ) shift 1; echo "Status $@"; systemctl status "$@" ;;
    * ) sudo systemctl "$@" ;;
  esac
}

# Function to easily start and stop openvpn service
function vpn() {
  local cmd=$1
  local endpoint=${2^^}
  local serv=openvpn@$endpoint
  case $cmd in
    d* )
      echo "Stopping $serv";
      sudo systemctl stop "$serv" ;;
    u* )
      echo "Starting $serv";
      sudo systemctl start "$serv" ;
      sudo journalctl -u $serv -f |
      while IFS= read line;
        do
          echo $line;
          if [[ $line =~ Initialization ]];
            then sudo pkill journalctl;
          fi;
      done;;
    r* )
      echo "Restarting $serv";
      sudo systemctl restart "$serv" ;
      sudo journalctl -u $serv -f |
      while IFS= read line;
        do
          echo $line;
          if [[ $line =~ Initialization ]];
            then sudo pkill journalctl;
          fi;
      done;;
    s* )
      echo "Status $serv"; systemctl status "$serv" ;;
    * )
      sudo systemctl "$serv" ;;
  esac
}
