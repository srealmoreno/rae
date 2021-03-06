#!/bin/python3
#####################################
#             UNAN-LEÓN             #
#  Script creado por Salvador Real  #
#     Redes de Area extensa 2020    #
#       Soporte para IPv6 2021      #
#####################################
from glob import glob
# To get all the files in a directory, with a unix-like pattern
from rstr import xeger
# To generate a text from a regular expression
from shutil import copy
# To copy files
from pathlib import Path
# To read the contents of a file quickly. this method opens, reads and closes the file
from json import dumps, load
# dumps to format a string in json format, load to load the content of a file in json format
from math import sqrt, atan, sin, cos
# sqrt for square root, atan is inverse tangent, sin is sine, cos is cosine
from sys import version as python_version
# To get the current version of python
from os import path, listdir, makedirs, symlink, unlink
# path is a group of useful methods for obtaining information from file system.
# path.isfile(X) return true is x is file
# listdir to know if a directory is empty
# makedirs make directory by recursive, similar to mkdir -p in linux
# symlink make symbolic link
# unlink remove symbolic link
from re import findall, IGNORECASE, MULTILINE
# findall is a method to search with regular expressions in a text
# IGNORECASE and MULTILINE are flags passed to the findall method
# IGNORECASE case insensitive search
# MULTILINE multiline search
from importlib.util import spec_from_file_location, module_from_spec
# To import a .py file from the filesystem.
from argparse import ArgumentParser, RawTextHelpFormatter, SUPPRESS
# For the command line
# RawTextHelpFormatter Allows me to add newlines "\ n" in the syntax


class MyNode:
    # Class that contains all the node information
    # This class is used when converting the topology

    # Statics vars
    TCP_PORT = 5000
    # In a GNS3 topology, each node is assigned two TCP ports
    # to identify the main console and auxiliary console. since the connection is by telnet
    N_NODES = 0
    # for index node
    # Constructor

    def __init__(self, console_port: int, console_auto_start: bool, console_type: str, name: str, type: str, properties: dict, symbol: str, template_id: str, x: int, y: int):
        self.console_port = console_port
        self.console_auto_start = console_auto_start
        # If true, a console starts automatically every time the node is powered on
        self.console_type = console_type
        #Telnet (Docker) or null (Hub)
        self.name = name
        # Name or hostname of node
        self.node_id = xeger(
            r'^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$')
        # Id of node
        self.type = type
        #Docker or ethernet_hub
        self.properties = properties
        # Additional node properties
        self.symbol = symbol
        # Symbol of node
        self.template_id = template_id
        self.adapters = 0
        # Number of adapters of node, if a link is added, this number will increase
        self.x = x
        self.y = y
        # Coordinates

        self.index = MyNode.N_NODES

        MyNode.N_NODES += 1


class AuxNode:
    # Since there is no constructor overload in python,
    # this class is helpful when using the config subcommand,
    # as only little data is required from the node

    # Constructor
    def __init__(self, node_id: str, index: int):
        self.node_id = node_id
        self.index = index


class GNS3Project:
    # Class containing all the project information
    # Constructor
    def __init__(self, name: str, gns3_version):

        # This is the base template of a GNS3 project
        self.project = {
            "auto_close": False,
            "auto_open": False,
            "auto_start": False,
            "drawing_grid_size": 25,
            "grid_size": 75,
            "name": name,
            "project_id": xeger(r'^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$'),
            "revision": 9,
            "scene_height": 1000,
            "scene_width": 2000,
            "show_grid": False,
            "show_interface_labels": True,
            "show_layers": False,
            "snap_to_grid": False,
            "supplier": None,
            "topology": {
                "computes": [],
                "drawings": [],
                "links": [],
                "nodes": []
            },
            "type": "topology",
            "variables": None,
            "version": gns3_version,
            "zoom": 100
        }

    # Add a node to the topology
    def append_node(self, Node: MyNode):
        self.project["topology"]["nodes"].append({
            "compute_id": "local",
            "console": Node.console_port,
            "console_auto_start": Node.console_auto_start,
            "console_type": Node.console_type,
            "custom_adapters": [],
            "first_port_name": None,
            "height": 59,
            "label": {
                "rotation": 0,
                "style": "font-family: TypeWriter;font-size: 10.0;font-weight: bold;fill: #000000;fill-opacity: 1.0;",
                "text": Node.name,
                "x": 16,
                "y": -25
            },
            "locked": False,
            "name": Node.name,
            "node_id": Node.node_id,
            "node_type": Node.type,
            "port_name_format": "Ethernet{0}",
            "port_segment_size": 0,
            "properties": Node.properties,
            "symbol": Node.symbol,
            "template_id": Node.template_id,
            "width": 65,
            "x": Node.x,
            "y": Node.y,
            "z": 1
        })

    # Creates a link between two nodes, also centers the interface tag
    def create_link(self, Node_in: MyNode, Node_out: MyNode):
        Vx = Node_out.x - Node_in.x
        Vy = Node_out.y - Node_in.y
        distance = int(sqrt((Vx**2) + Vy**2) * 0.20)

        if Vx != 0:
            # Dx = int(distance * abs((Vx / sqrt(Vx**2 + Vy**2)))))
            # Dy = int(distance * abs((Vy / sqrt(Vx**2 + Vy**2)))))
            tehta = atan(abs(Vy/Vx))
            Dx = int(distance * abs(cos(tehta)))
            Dy = int(distance * abs(sin(tehta)))
        else:
            Dx = 0
            Dy = distance

        self.project["topology"]["links"].append({
            "filters": {},
            "link_id": xeger(r'^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$'),
            "nodes": [
                {
                    "adapter_number": Node_in.adapters if Node_in.type == "docker" else 0,
                    "label": {
                        "rotation": 0,
                        "style": "font-family: TypeWriter;font-size: 10.0;fill: #000000;fill-opacity: 1.0;",
                        "text": "eth" + str(Node_in.adapters) if Node_in.type == "docker" else "",
                        "x": Dx if Vx > 0 else Dx * -1,
                        "y": Dy if Vy > 0 else Dy * -1
                    },
                    "node_id": Node_in.node_id,
                    "port_number": 0 if Node_in.type == "docker" else Node_in.adapters
                },
                {
                    "adapter_number": Node_out.adapters if Node_out.type == "docker" else 0,
                    "label": {
                        "rotation": 0,
                        "style": "font-family: TypeWriter;font-size: 10.0;fill: #000000;fill-opacity: 1.0;",
                        "text": "eth" + str(Node_out.adapters) if Node_out.type == "docker" else "",
                        "x": Dx * -1 if Vx > 0 else Dx,
                        "y": Dy * -1 if Vy > 0 else Dy
                    },
                    "node_id": Node_out.node_id,
                    "port_number": 0 if Node_out.type == "docker" else Node_out.adapters
                }
            ],
            "suspend": False
        })

        if Node_in.type == "docker":
            self.project["topology"]["nodes"][Node_in.index]["properties"]["adapters"] += 1
        else:
            self.project["topology"]["nodes"][Node_in.index]["properties"]["ports_mapping"].append({
                "name": "eth" + str(Node_in.adapters),
                "port_number": Node_in.adapters
            })

        Node_in.adapters += 1

        if Node_out.type == "docker":
            self.project["topology"]["nodes"][Node_out.index]["properties"]["adapters"] += 1
        else:
            self.project["topology"]["nodes"][Node_out.index]["properties"]["ports_mapping"].append({
                "name": "eth" + str(Node_out.adapters),
                "port_number": Node_out.adapters
            })

        Node_out.adapters += 1

    # Return project in json value
    def get_value(self) -> str:
        return dumps(self.project, indent=4)


# recursive copy method
def copy_subfolder(src: str, dst: str):
    if not src.endswith("/"):
        src += "/"
    if not dst.endswith("/"):
        dst += "/"
    for i in listdir(src):
        if path.isdir(src+i):
            makedirs(dst+i+"/", exist_ok=True)
            copy_subfolder(src+i, dst+i)
        elif path.isfile(src+i):
            if path.basename(path.dirname(src+i)) != "etc":
                copy(src+i, dst)
            else:
                # If the file is in the "/etc/" folder, copy the file to the "root/.etc/" directory,
                # since there is no file persistence in docker
                makedirs(path.dirname(path.dirname(dst+i)) +
                         "/root/.etc", exist_ok=True)

                if i == "hosts":
                    # If it is the hosts file, it only copies IPv6 addresses since in a GNS3 project,
                    # the hosts IPv4 are saved in additional properties of the node
                    ipv6_hosts = get_etc_hosts(
                        src+i, IPv4=False, IPv6=True)
                    if ipv6_hosts != None:
                        for i in ipv6_hosts.splitlines():
                            # This is to remove duplicate name-addresses if file /etc/hosts
                            # or not add the name-address if it already exists
                            regex = r"^[\t ]*" + \
                                " ".join(i.split()).translate(
                                    str.maketrans({'.': '\\.', ' ': '[\\t ]+'})) + "[\\t ]*$"
                            with open(path.dirname(path.dirname(dst+i))+"/root/.etc/hosts", "a+") as hosts_file:
                                hosts_file.seek(0)
                                if findall(regex, "".join(hosts_file.readlines()), flags=MULTILINE) == []:
                                    hosts_file.write(i+"\n")
                else:
                    copy(src+i, path.dirname(path.dirname(dst+i))+"/root/.etc")


def centrate_topology(Project: GNS3Project):
    # This method centers the topology
    for i in Project.project["topology"]["nodes"]:
        if 'min_x' not in locals() and 'min_x' not in globals():
            min_x = i["x"]
        elif min_x > i["x"]:
            min_x = i["x"]

        if 'max_x' not in locals() and 'max_x' not in globals():
            max_x = i["x"]
        elif max_x < i["x"]:
            max_x = i["x"]

        if 'min_y' not in locals() and 'min_y' not in globals():
            min_y = i["y"]
        elif min_y > i["y"]:
            min_y = i["y"]

        if 'max_y' not in locals() and 'max_y' not in globals():
            max_y = i["y"]
        elif max_y < i["y"]:
            max_y = i["y"]

        displacement_x = min_x + ((max_x - min_x) // 2)
        displacement_y = min_y + ((max_y - min_y) // 2)

    for i in Project.project["topology"]["nodes"]:
        i["x"] -= displacement_x
        i["y"] -= displacement_y


def get_etc_hosts(file: str, IPv4: bool = True, IPv6: bool = False):
    if not file.endswith("/etc/hosts"):
        if not file.endswith("/"):
            file += "/etc/hosts"
        else:
            file += "etc/hosts"

    regex_ipv4 = r"^((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))[\t ]+(.*\S)[\t ]*$"
    regex_ipv6 = r"^[\t ]*(?:(?:[0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|(?:[0-9a-fA-F]{1,4}:){1,7}:|(?:[0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|(?:[0-9a-fA-F]{1,4}:){1,5}(?::[0-9a-fA-F]{1,4}){1,2}|(?:[0-9a-fA-F]{1,4}:){1,4}(?::[0-9a-fA-F]{1,4}){1,3}|(?:[0-9a-fA-F]{1,4}:){1,3}(?::[0-9a-fA-F]{1,4}){1,4}|(?:[0-9a-fA-F]{1,4}:){1,2}(?::[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:(?:(?::[0-9a-fA-F]{1,4}){1,6})|:(?:(?::[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(?::[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(?:ffff(?::0{1,4}){0,1}:){0,1}(?:(?:25[0-5]|(?:2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(?:25[0-5]|(?:2[0-4]|1{0,1}[0-9]){0,1}[0-9])|(?:[0-9a-fA-F]{1,4}:){1,4}:(?:(?:25[0-5]|(?:2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(?:25[0-5]|(?:2[0-4]|1{0,1}[0-9]){0,1}[0-9]))[\t ]+(?:.*[\S])[\t ]*$"
    regex_del_redundancy_ipv6 = r"^(?![\t ]*(?:::1[\t ]+(?:localhost)*ip6-localhost[\t ]+ip6-loopback|fe00::0[\t ]+ip6-localnet|ff00::0[\t ]+ip6-mcastprefix|ff02::1[\t ]+ip6-allnodes|ff02::2[\t ]+ip6-allrouters)[\t ]*$).+\S"
    hosts = ''
    if path.isfile(file):
        if IPv4:
            for i in findall(regex_ipv4, Path(file).read_text(), flags=MULTILINE):
                if hosts != "":
                    hosts += "\n"
                hosts += i[1]+":"+i[0]
                # format: hostname:IPv4

        # GNS3 no support IPv6 :c in extra hosts
        if IPv6:
            ipv6_matches = "\n".join(findall(regex_ipv6,
                                             Path(file).read_text(), flags=MULTILINE))
            hosts += "\n".join(findall(regex_del_redundancy_ipv6,
                                       ipv6_matches, flags=MULTILINE))
            # for i in findall(regex_ipv6, Path(file).read_text(), flags=MULTILINE):
            #    if hosts != "":
            #        hosts += "\n"
            #    hosts += i[0]+i[1]

    return hosts if hosts != '' else None


def convert_topology(pjNetgui: str, pjOutput: str, nameOutput: str,  imgDocker: str, template_id: str, cfgRead: str, netgui_file: str, gns3_version: str, copy_hosts: bool):

    if not pjOutput.endswith("/"):
        pjOutput += "/"
    if path.exists(pjOutput+nameOutput):
        if not (path.isdir(pjOutput+nameOutput) and not listdir(pjOutput+nameOutput)):
            print(pjOutput+nameOutput +
                  "\033[91m a file or directory already exists\033[0m")
            exit(1)

    project = GNS3Project(name=nameOutput, gns3_version=gns3_version)

    if template_id == None:
        if path.isfile(cfgRead):
            with open(cfgRead) as json_file:
                for i in load(json_file)["templates"]:
                    if i["template_type"].lower() == "docker" and i["image"].lower() == imgDocker.lower():
                        template_id = i["template_id"]
                        break
                if template_id == None:
                    print("\033[91mNot exists template of\033[0m '%s' \033[91min\033[0m '%s'" %
                          (imgDocker, cfgRead))
                    exit(1)
        else:
            print(cfgRead + "\033[91m No such file GNS3 Controller\033[0m")
            exit(1)

    if findall(r'^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$', template_id) == []:
        print(
            "\033[91mInvalid template ID:\033[0m %s\n\033[94mIt must have this format:\033[0m ^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}" % template_id)
        exit(1)

    nodes = {}
    nodes_in_file = findall(
        r"^[\t ]*position[\t ]*\([\t ]*(-?[0-9]+)\.[0-9]*[\t ]*,[\t ]*(-?[0-9]+)\.[0-9]*[\t ]*\)[\t ]*;[\t ]*(NKCompaq|NKRouter|NKSwitch|NKHub)[\t ]*\([\t ]*\"[\t ]*(.+?)[\t ]*\"[\t ]*\).*$", netgui_file, flags=IGNORECASE | MULTILINE)

    """
        Since the syntax of a node is the following:
            position(coordinates.x, coordinates.y); type_of_node(name_of_node)

            The coordinates of a node are in decimal, but the coordinates of a node in GNS3 are integers.

        This regex allows me to extract:
        Group 0: Coordinates on the X axis (Without decimal)
        Group 1: Coordinates on the Y axis (Without decimal)
        Group 2: Node Type
        Group 3: Node name                 (Without whitespace at the beginning or end)

        In addition, it does not break with comments between the statements

        Matches Example:

            --------------------------------------------
            position(268.10,125.0);NKHub("hub1")
                result = (268, 125, "Nkhub", "hub1")
            --------------------------------------------

            --------------------------------------------
            position(568.990,12.11); #comment
            #comment
            NKCompaq("   pc   1  ")#comment
                result = (568, 990, "NKCompaq", "pc   1")
            ---------------------------------------------

    """
    if nodes_in_file == []:
        print("\033[93mNodes of topology not found in \033[0m", pjNetgui)
    else:
        for current_node in nodes_in_file:
            if not current_node[3] in nodes:
                if current_node[2].lower() == "nkhub":
                    # These are the properties of a hub type node.
                    # Here the ports of the interfaces are mapped.
                    properties = {
                        "ports_mapping": []
                    }
                    nodes[current_node[3]] = MyNode(console_port=None, console_auto_start=False, console_type=None, name=current_node[3], type="ethernet_hub",
                                                    properties=properties, symbol=":/symbols/hub.svg", template_id="b4503ea9-d6b6-3695-9fe4-1db3b39290b0", x=int(current_node[0]), y=int(current_node[1]))
                else:
                    # These are the properties of a docker type node.
                    #   the IPv4 host names go in the EXTRA_HOSTS parameter (Only IPv4, no support IPv6)
                    # The IPv6 Hosts variable is in case there is any IPv6 hostname, this variable will be used by the docker image to load the hostnames at startup
                    properties = {
                        "adapters": 0,
                        "aux": MyNode.TCP_PORT + 1,
                        "console_http_path": "/",
                        "console_http_port": 80,
                        "console_resolution": "800x600",
                        "container_id": xeger(r'^[a-f0-9]{12,64}$'),
                        "environment": "IPv6_Hosts=yes" if copy_hosts and get_etc_hosts(pjNetgui+current_node[3], IPv4=False, IPv6=True) != None else None,
                        "extra_hosts": get_etc_hosts(pjNetgui+current_node[3]) if copy_hosts else None,
                        "extra_volumes": None,
                        "image": imgDocker,
                        "start_command": None,
                        "usage": ""
                    }
                    if current_node[2].lower() == "nkcompaq":
                        properties["extra_volumes"] = [
                            "/save/", "/etc/network", "/etc/default", "/root/"]
                        symbol = ":/symbols/classic/computer.svg"
                    elif current_node[2].lower() == "nkrouter":
                        properties["extra_volumes"] = ["/save", "/etc/network",
                                                       "/etc/default", "/etc/dhcp", "/etc/frr", "/root/"]
                        symbol = ":/symbols/classic/router.svg"
                    else:
                        properties["extra_volumes"] = [
                            "/save/", "/etc/network", "/etc/default", "/root/"]
                        symbol = ":/symbols/classic/ethernet_switch.svg"
                    nodes[current_node[3]] = MyNode(
                        console_port=MyNode.TCP_PORT, console_auto_start=True, console_type="telnet", name=current_node[3], type="docker", properties=properties, symbol=symbol, template_id=template_id, x=int(current_node[0]), y=int(current_node[1]))
                    MyNode.TCP_PORT += 2

                project.append_node(nodes[current_node[3]])
            else:
                print("\033[91mError in convert topology, duplicate node\033[0m \"%s\"\033[93m\nNode names must be unique.\033[0m" %
                      current_node[3])
                exit(1)

        links_in_file = findall(
            r"^[\t ]*Connect[\t ]*\([\t ]*\"[\t ]*(.+?)[\t ]*\"[\t ]*\)(?:(?!Connect|To)[\w\W])*^[\t ]*To[\t ]*\([\t ]*\"[\t ]*(.+?)[\t ]*\"[\t ]*\).*$", netgui_file, flags=IGNORECASE | MULTILINE)
        """
            Since the syntax of a link is the following:
                Connect(name_of_node)
                To(name_of_node)
                
            This regex allows me to extract:
            Group 0: Connection_from  (Without whitespace at the beginning or end)
            Group 1: Connection_to    (Without whitespace at the beginning or end)
            
            In addition, it does not break with comments between the statements

            Matches Example:

                ----------------------------
                Connect("pc1")
                To("hub1")
                result = ("pc1", "hub1")
                ----------------------------

                ----------------------------
                Connect("pc2") #comment
                #comment
                #comment
                To("    s    1    ")#comment
                result = ("pc2", "s   1")
                ----------------------------

        """

        if links_in_file == []:
            print("\033[93mLinks of topology not found in \033[0m", pjNetgui)
        else:
            for node_in, node_out in links_in_file:
                try:
                    if node_in == node_out:
                        print("\033[93mSkipping link from \033[0m\"%s\" \033[93mto\033[0m \"%s\"\033[91m cannot connect to itself\033[0m" % (
                            node_in, node_out))
                        continue
                    project.create_link(
                        nodes[node_in], nodes[node_out])
                # except IndexError:
                #    print("\033[93mSkipping link from\033[0m \"%s\" \033[93mto\033[0m ??\033[91m unfinished link\033[0m" %
                #          node_in)
                except KeyError as error:
                    if error.args[0] != node_in:
                        from_ = node_out
                        to_ = error.args[0]
                    else:
                        from_ = error.args[0]
                        to_ = node_out

                    print("\033[93mSkipping link from\033[0m \"%s\" \033[93mto\033[0m \"%s\"\033[91m not exists node\033[0m \"%s\"\033[91m in netgui topology\033[0m" %
                          (from_, to_, error.args[0]))

        centrate_topology(project)

        makedirs(pjOutput+nameOutput, exist_ok=True)
        with open(pjOutput+nameOutput+"/"+nameOutput+".gns3", 'w') as gns3_file:
            gns3_file.write(project.get_value())
            print("\033[92mSuccessfully converted topology saved in:\033[0m\n%s" %
                  pjOutput+nameOutput+"/")

    return nodes


def convert_files(pjNetgui: str, pjOutput: str, netgui_file: str, nodes: dict = None):
    if nodes == None:
        if path.isdir(pjOutput):
            if not pjOutput.endswith("/"):
                pjOutput += "/"
            all_match = glob(pjOutput+'*.gns3')
            if len(all_match) == 0:
                print("\033[91mNot exists file *.gns3 in\033[0m " + pjOutput)
                exit(1)
            elif len(all_match) > 1:
                print(
                    "\033[93mAmbiguous Directory\n\033[94mWhat is project?\033[0m")
                for i in all_match:
                    print(i)
                print(
                    "\033[91mPlease pass the full name of the project file as an argument\033[0m")
                exit(1)
            else:
                pjOutput = all_match[0]
                gns3_file = Path(all_match[0]).read_text()
        elif path.isfile(pjOutput):
            if not pjOutput.lower().endswith(".gns3"):
                print(pjOutput + "\033[91mIsn't project of gns3\033[0m")
                exit(1)
            else:
                gns3_file = Path(pjOutput).read_text()
        else:
            print(pjOutput + "\033[91m Isn't file or directory\033[0m")
            exit(1)
        nodes = {}
        with open(pjOutput, "r") as json_file:
            project = load(json_file)
            j = 0
            for i in project["topology"]["nodes"]:
                if i["node_type"].lower() == "docker":
                    nodes[i["name"]] = AuxNode(node_id=i["node_id"], index=j)
                j += 1
    else:
        project = None

    copy_successfull = False
    changes_detect = False

    for i in findall(r"[\t ]*(?:NKCompaq|NKRouter|NKSwitch)[\t ]*\([\t ]*\"(.+)[\t ]*\"[\t ]*\)[\t ]*$", netgui_file, flags=IGNORECASE | MULTILINE):
        try:
            folder_base = path.dirname(pjOutput)+"/project-files/docker/" + \
                nodes[i].node_id
            makedirs(folder_base+"/root", exist_ok=True)
            makedirs(folder_base+"/save", exist_ok=True)

            if not path.exists(path.dirname(folder_base)+"/"+i):
                symlink(path.basename(folder_base),
                        path.dirname(folder_base)+"/"+i)
            else:
                unlink(path.dirname(folder_base)+"/"+i)
                symlink(path.basename(folder_base),
                        path.dirname(folder_base)+"/"+i)

            if project != None:
                node_hosts_ipv6 = get_etc_hosts(
                    pjNetgui, IPv4=False, IPv6=True)

                if node_hosts_ipv6 != None:
                    if project["topology"]["nodes"][nodes[i].index]["properties"]["environment"] == None:
                        project["topology"]["nodes"][nodes[i]
                                                     .index]["properties"]["environment"] = "IPv6_Hosts=yes"
                        changes_detect = True
                    elif "IPv6_Hosts=yes" not in project["topology"]["nodes"][nodes[i]
                                                                              .index]["properties"]["environment"]:
                        project["topology"]["nodes"][nodes[i]
                                                     .index]["properties"]["environment"] += "\nIPv6_Hosts=yes"
                        changes_detect = True

                node_hosts_ipv4 = get_etc_hosts(pjNetgui+i)
                if node_hosts_ipv4 != None:
                    if project["topology"]["nodes"][nodes[i].index]["properties"]["extra_hosts"] == None:
                        project["topology"]["nodes"][nodes[i]
                                                     .index]["properties"]["extra_hosts"] = node_hosts_ipv4
                        changes_detect = True
                    else:
                        for j in node_hosts_ipv4.splitlines():
                            if j not in project["topology"]["nodes"][nodes[i].index]["properties"]["extra_hosts"]:
                                project["topology"]["nodes"][nodes[i]
                                                             .index]["properties"]["extra_hosts"] += "\n" + j
                                changes_detect = True

            if path.isdir(pjNetgui+i):
                copy_subfolder(src=pjNetgui+i, dst=folder_base)
                copy_successfull = True
            elif path.isdir(pjNetgui+i+".old"):
                copy_subfolder(src=pjNetgui+i+".old", dst=folder_base)
                copy_successfull = True
            if path.isfile(pjNetgui+i+".startup"):
                copy(pjNetgui+i+".startup", folder_base+"/root")
                copy_successfull = True

        except KeyError:
            print(
                "\033[93mSkipping\033[0m \"%s\"\033[91m Not exists in GNS3 topology or isn't docker type.\033[0m" % i)

    if changes_detect:
        with open(pjOutput, 'w') as gns3_file:
            gns3_file.write(dumps(project, indent=4))

    if changes_detect or copy_successfull:
        print("\033[92mSuccessfully converted config files\033[0m")
    else:
        print("\033[93mNo configuration files found\033[0m")


def convert_project(pjNetgui: str, pjOutput: str, nameOutput: str = None, imgDocker: str = None, template_id: str = None, cfgRead: str = None, convertConfig: str = True, convertTopology: bool = True, gns3_version: str = None):
    if not path.exists(pjNetgui):
        print(pjNetgui + "\033[91m No such file or directory\033[0m")
        exit(1)

    if path.isdir(pjNetgui):
        if not pjNetgui.endswith("/"):
            pjNetgui += "/"
        all_match = glob(pjNetgui+'*.nkp')
        if len(all_match) == 0:
            print("\033[91mNot exists file *.nkp in\033[0m " + pjNetgui)
            exit(1)
        elif len(all_match) > 1:
            print("\033[93mAmbiguous Directory\n\033[94mWhat is project?\033[0m")
            for i in all_match:
                if (i.lower().endswith("/netgui.nkp")):
                    while True:
                        print(i+"\033[92m <- Use this? (S/n)\033[0m ", end="")
                        resp = input()
                        if resp.lower() == "s":
                            netgui_file = Path(i).read_text()
                            break
                        elif resp.lower() == "n":
                            print(
                                "\033[91mPlease pass the full name of the project file as an argument\033[0m")
                            break
                    if resp.lower() == "s":
                        break
                else:
                    print(i)

            if 'resp' not in locals() and 'resp' not in globals():
                print(
                    "\033[91mPlease pass the full name of the project file as an argument\033[0m")
            if 'netgui_file' not in locals() and 'netgui_file' not in globals():
                exit(1)
        else:
            netgui_file = Path(all_match[0]).read_text()
    elif path.isfile(pjNetgui):
        if not pjNetgui.lower().endswith(".nkp"):
            print(pjNetgui + "\033[91m Isn't project of netgui\033[0m")
            exit(1)
        else:
            netgui_file = Path(pjNetgui).read_text()
            pjNetgui = path.dirname(pjNetgui)+"/"
    else:
        print(pjNetgui + "\033[91m Isn't file or directory\033[91m")
        exit(1)

    nodes = None

    if convertTopology:
        if nameOutput == "Netgui project name":
            nameOutput = path.basename(path.dirname(pjNetgui))

        nodes = convert_topology(pjNetgui=pjNetgui, pjOutput=pjOutput, nameOutput=nameOutput,
                                 imgDocker=imgDocker, template_id=template_id,  cfgRead=cfgRead, netgui_file=netgui_file, gns3_version=gns3_version, copy_hosts=convertConfig)
        if convertConfig:
            pjOutput += "/"+nameOutput+"/"+nameOutput+".gns3"

    if convertConfig:
        convert_files(pjNetgui=pjNetgui, pjOutput=pjOutput,
                      netgui_file=netgui_file, nodes=nodes)


if __name__ == '__main__':
    try:
        spec = spec_from_file_location(
            "version", "/usr/share/gns3/gns3-gui/lib/python" + python_version[0] + "." + python_version[2] + "/site-packages/gns3/version.py")
        gns3 = module_from_spec(spec)
        spec.loader.exec_module(gns3)
    except FileNotFoundError:
        print("\033[91mGNS3 not installed\033[0m")
        exit(1)
    pass

    version = "{}.{}".format(gns3.__version_info__[
        0], gns3.__version_info__[1])
    gns3_version = gns3.__version__

    # create the top-level parser
    parser = ArgumentParser(
        formatter_class=RawTextHelpFormatter, add_help=False, description="Convert Topology Netgui to GNS3 with Docker")

    parser._positionals.title = "required argument"

    parser.add_argument('-h', '--help', action='help', default=SUPPRESS,
                        help='show this help message and exit\n ')

    parser.add_argument('-v', '--version', action='version',
                        help='show program version and exit', version='%(prog)s 1.0')

    subparsers = parser.add_subparsers(dest='command', required=True)

    # create the parser for the "all" command

    parser_a = subparsers.add_parser(
        'all', help='convert toplogy and config files', formatter_class=RawTextHelpFormatter, add_help=False, description='Convert toplogy and config files')

    parser_a._positionals.title = "required argument"

    exclusive_a = parser_a.add_mutually_exclusive_group()

    parser_a.add_argument('-h', '--help', action='help', default=SUPPRESS,
                          help='show this help message and exit\n ')

    parser_a.add_argument('-i', '--image', type=str, default="srealmoreno/rae:latest",
                          help='    base docker image to use\n\tdefault: %(default)s\n ', metavar='\b')

    parser_a.add_argument('-n', '--name', type=str, default="Netgui project name",
                          help='    gns3 project name\n\tdefault: %(default)s\n ', metavar='\b')

    exclusive_a.add_argument('-t', '--template', type=str,
                             help='    specifies the ID of the Docker template.\n ', metavar='\b')

    exclusive_a.add_argument('-r', '--read', type=str, default=path.expanduser("~/.config/GNS3/"+version+"/gns3_controller.conf"),
                             help='    path of GNS3 controller config. The template ID will\nbe searched here in case it is not specified (-t)\n\tdefault: %(default)s\n ', metavar='\b')

    parser_a.add_argument('-o', '--output', type=str, default=path.expanduser("~/GNS3/projects/"),
                          help='    output folder\n\tdefault: %(default)s', metavar='\b')

    parser_a.add_argument('netgui_project', type=str,
                          help='netgui project folder to convert')

    # create the parser for the "topology" command
    parser_b = subparsers.add_parser(
        'topology', help='convert only topology', formatter_class=RawTextHelpFormatter, add_help=False, description='Convert only topology')

    parser_b._positionals.title = "required argument"

    exclusive_b = parser_b.add_mutually_exclusive_group()

    parser_b.add_argument('-h', '--help', action='help', default=SUPPRESS,
                          help='show this help message and exit\n ')

    parser_b.add_argument('-i', '--image', type=str, default="srealmoreno/rae:latest",
                          help='    base docker image to use\n\tdefault: %(default)s\n ', metavar='\b')

    parser_b.add_argument('-n', '--name', type=str, default="Netgui project name",
                          help='    gns3 project name\n\tdefault: %(default)s\n ', metavar='\b')

    exclusive_b.add_argument('-t', '--template', type=str,
                             help='    specifies the ID of the Docker template.\n ', metavar='\b')

    exclusive_b.add_argument('-r', '--read', type=str, default=path.expanduser("~/.config/GNS3/"+version+"/gns3_controller.conf"),
                             help='    path of GNS3 controller config. The template ID will\nbe searched here in case it is not specified (-t)\n\tdefault: %(default)s\n ', metavar='\b')

    parser_b.add_argument('-o', '--output', type=str, default=path.expanduser("~/GNS3/projects/"),
                          help='    output folder\n\tdefault: %(default)s', metavar='\b')

    parser_b.add_argument('netgui_project', type=str,
                          help='netgui project folder to convert')

    # create the parser for the "config" command
    parser_c = subparsers.add_parser(
        'config', help='convert only config files', formatter_class=RawTextHelpFormatter, description='Convert only config files')

    parser_c._positionals.title = "required arguments"

    parser_c._optionals.title = "optional argument"

    parser_c.add_argument('netgui_project', type=str,
                          help='netgui project folder to convert\n ')
    parser_c.add_argument('gns3_project', type=str,
                          help='gns3 project folder to convert')

    args = parser.parse_args()

    if args.command == "all":
        convert_project(pjNetgui=path.abspath(args.netgui_project),
                        pjOutput=path.abspath(args.output), nameOutput=args.name, imgDocker=args.image, template_id=args.template, cfgRead=path.abspath(args.read), gns3_version=gns3.__version__)
    elif args.command == "topology":
        convert_project(pjNetgui=path.abspath(args.netgui_project),
                        pjOutput=path.abspath(args.output), nameOutput=args.name, imgDocker=args.image, template_id=args.template, cfgRead=path.abspath(args.read), convertConfig=False, gns3_version=gns3.__version__)
    else:
        convert_project(pjNetgui=path.abspath(args.netgui_project),
                        pjOutput=path.abspath(args.gns3_project), convertTopology=False)
