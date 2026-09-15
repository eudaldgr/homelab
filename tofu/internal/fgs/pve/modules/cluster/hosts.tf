resource "proxmox_virtual_environment_hosts" "main" {
  for_each  = var.nodes
  node_name = each.key

  # IPv4 localhost entries
  entry {
    address = "127.0.0.1"

    hostnames = [
      "localhost.localdomain",
      "localhost",
    ]
  }
  entry {
    address = each.value.address

    hostnames = [
      "${each.key}.${var.dns.domain}",
      each.key,
    ]
  }

  # IPv6 localhost entries
  # The following lines are desirable for IPv6 capable hosts
  entry {
    address = "::1"

    hostnames = [
      "ip6-localhost",
      "ip6-loopback",
    ]
  }
  entry {
    address = "fe00::0"

    hostnames = [
      "ip6-localnet",
    ]
  }
  entry {
    address = "ff00::0"

    hostnames = [
      "ip6-mcastprefix",
    ]
  }
  entry {
    address = "ff02::1"

    hostnames = [
      "ip6-allnodes",
    ]
  }
  entry {
    address = "ff02::2"

    hostnames = [
      "ip6-allrouters",
    ]
  }
  entry {
    address = "ff02::3"

    hostnames = [
      "ip6-allhosts",
    ]
  }
}
