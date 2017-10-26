# ======================================================================
# Define options
# ======================================================================

set val(chan)       		Channel/WirelessChannel
set val(prop)       		Propagation/Nakagami
set val(netif)      		Phy/WirelessPhy
set val(mac)        		Mac/802_11
set val(ifq)        		Queue/DropTail/PriQueue
set val(ll)         		LL
set val(ant)        		Antenna/OmniAntenna
set opt(x)              510   				;# X dimension of the topography
set opt(y)              510   				;# Y dimension of the topography
set val(ifqlen)         50            ;# max packet in ifq
set val(nn)             50            ;# how many nodes are simulated
set val(seed)						0.0
set val(adhocRouting)   AODV
set val(stop)           100          	;# simulation time
set val(cp)							"cbrtest.txt"	;#<-- traffic file
set val(sc)							"scena10.txt"	;#<-- mobility file 

Phy/WirelessPhy	set	RXThresh_ 1.42681e-08 ;#100m
# =====================================================================
# Main Program
# ======================================================================
# Initialize Global Variables
# create simulator instance

set ns_		[new Simulator]

# setup topography object

set topo	[new Topography]

# create trace object for ns and nam

set tracefd	[open aodv_outnakaa10.tr w]
set namtrace    [open aodv_outnakaa10.nam w]

$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace $opt(x) $opt(y)

# set up topology object
set topo				[new Topography]
$topo load_flatgrid $opt(x) $opt(y)

# Create God
set god_ [create-god $val(nn)]

#global node setting
$ns_ node-config -adhocRouting $val(adhocRouting) \
                 -llType $val(ll) \
                 -macType $val(mac) \
                 -ifqType $val(ifq) \
                 -ifqLen $val(ifqlen) \
                 -antType $val(ant) \
                 -propType $val(prop) \
                 -phyType $val(netif) \
				         -channelType $val(chan) \
				         -topoInstance $topo \
				         -agentTrace ON \
				         -routerTrace ON \
				         -macTrace ON \
				         -movementTrace ON \
								 
###

# 802.11p default parameters

Phy/WirelessPhyExt set CSThresh_                3.9810717055349694e-13	;# -94 dBm wireless interface sensitivity
Phy/WirelessPhyExt set Pt_                      0.1			;# equals 20dBm when considering antenna gains of 1.0
Phy/WirelessPhyExt set freq_                    5.9e+9
Phy/WirelessPhyExt set noise_floor_             1.26e-13    		;# -99 dBm for 10MHz bandwidth
Phy/WirelessPhyExt set L_                       1.0         		;# default radio circuit gain/loss
Phy/WirelessPhyExt set PowerMonitorThresh_      3.981071705534985e-18   ;# -174 dBm power monitor sensitivity (=level of gaussian noise)
Phy/WirelessPhyExt set HeaderDuration_          0.000040    		;# 40 us
Phy/WirelessPhyExt set BasicModulationScheme_   0
Phy/WirelessPhyExt set PreambleCaptureSwitch_   1
Phy/WirelessPhyExt set DataCaptureSwitch_       1
Phy/WirelessPhyExt set SINR_PreambleCapture_    3.1623;     		;# 5 dB
Phy/WirelessPhyExt set SINR_DataCapture_        10.0;      		;# 10 dB
Phy/WirelessPhyExt set trace_dist_              1e6         		;# PHY trace until distance of 1 Mio. km ("infinity")
Phy/WirelessPhyExt set PHY_DBG_                 0

Mac/802_11Ext set CWMin_                        15
Mac/802_11Ext set CWMax_                        1023
Mac/802_11Ext set SlotTime_                     0.000013
Mac/802_11Ext set SIFS_                         0.000032
Mac/802_11Ext set ShortRetryLimit_              7
Mac/802_11Ext set LongRetryLimit_               4
Mac/802_11Ext set HeaderDuration_               0.000040
Mac/802_11Ext set SymbolDuration_               0.000008
Mac/802_11Ext set BasicModulationScheme_        0
Mac/802_11Ext set use_802_11a_flag_             true
Mac/802_11Ext set RTSThreshold_                 2346
Mac/802_11Ext set MAC_DBG                       0

###
#  Create the specified number of nodes [$val(nn)] and "attach" them
#  to the channel. 
for {set i 0} {$i < $val(nn)} {incr i} {
		set node_($i) [$ns_ node]
		$node_($i) random-motion 0 ;# disable random motion
}

# Define node movement model
puts "Loading connection pattern..."
source $val(cp)

# Define traffic model
puts "Loading scenario file..."
source $val(sc)

# Define node initial position in nam

for {set i 0} {$i < $val(nn)} {incr i} {

    # 20 defines the node size in nam, must adjust it according to your scenario
    # The function must be called after mobility model is defined
    
    $ns_ initial_node_pos $node_($i) 20
}

# Tell nodes when the simulation ends
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop).0 "$node_($i) reset";
}

#$ns_ at  $val(stop)	"stop"
$ns_ at  $val(stop).0002 "puts \"NS EXITING...\" ; $ns_ halt"

puts $tracefd "M 0.0 nn $val(nn) x $opt(x) y $opt(y) rp $val(adhocRouting)"
puts $tracefd "M 0.0 sc $val(sc) cp $val(cp) seed $val(seed)"
puts $tracefd "M 0.0 prop $val(prop) ant $val(ant)"

puts "Starting Simulation..."
$ns_ run
