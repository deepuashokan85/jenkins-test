resource "google_compute_instance" "web" {
    count = "${var.vm_count}"
    name = "${var.vm_name}"
    machine_type = "${var.machine_type}"
    zone = "${var.zone_id}"

  metadata = "${merge(map("sshKeys",format("jenkins:%s ",file(var.pubKeyFile))),
                      var.instance_metadata)}"

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }

  boot_disk {
    initialize_params {
      size  = 200
      image = "${var.image_id}"
    }
  }


  network_interface {
    subnetwork = "${var.subnetwork_id}"
  }

    scheduling {
        preemptible = false
        on_host_maintenance = "MIGRATE"
        automatic_restart = true
    }

  provisioner "file" {

  connection {
    type = "ssh"
    user = "jenkins"
    private_key = "${file("${var.priv_key}")}"
    agent = false
  }

  source        = "files/web-provision.sh"
  destination   = "/tmp/web-provision.sh"

    }
  provisioner "remote-exec" {

    connection {
    type = "ssh"
    user = "jenkins"
    private_key = "${file("${var.priv_key}")}"
    agent = false
     }

    inline = [
    "sudo chmod +x /tmp/web-provision.sh",
    "sudo bash -c /tmp/web-provision.sh"
    ]
  }
}
