# This is a sample Python script.

# Press Shift+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.

import random
import subprocess as subprocess
import os


def set_up(player_num, room_num,selected_killer):
    # create a new file that
    set_up = open(os.path.join("data","set_up.lp"), "w")
    for x in range(1, player_num+1):
        # wrtie out rules defining each player
        set_up.write("player(%s). \n" % (x))
    for y in range(1, room_num+1):
        # wrtie out rules defining each room
        set_up.write("room(%s). \n" % (y))
    set_up.write("killer(%s). \n" % (selected_killer))
    # troll = random.randint(1,player_num+1);
    # set_up.write("troll(player).")

    set_up.close()
def progress_turn(player_num, room_num,turn):
    # progress a turn and fill in supposed information
    turn_data = open(os.path.join("data","turn_%s.lp" % (turn)),"w")
    unlucky_agent = random.randint(1,player_num)
    # a while loop to progress the game
    # while(not game_over):
    for x in range(1, player_num+1):
        # simulating the selection of a room by the agents
        selected_room = random.randint(1, room_num)
        turn_data.write("choose(player(%s),room(%s),turn(%s)).\n"%(x,selected_room,turn))
    turn_data.write("turn(%s).\n"%(turn))
    # turn_data.write("k_c(player(%s),turn(%s)).\n" % (unlucky_agent, turn))
    turn_data.close()

def parse_scasp_output(scasp_out):
    # locate key pattern
    for element in scasp_out:
        if ('no models' in element):
            return False
    return True
if __name__ == '__main__':

    # absolute path to LOCAL files
    local_path = "/mnt/c/Users/13365/OneDrive/桌面/Linux-Ubuntu/Among_us_scasp/data"
    scasp = "scasp"
    flag = ["--sasp_forall"," --dcc"]
    query = "/mnt/c/Users/13365/OneDrive/桌面/Linux-Ubuntu/Among_us_scasp/query.lp"
    rules = "/mnt/c/Users/13365/OneDrive/桌面/Linux-Ubuntu/Among_us_scasp/rules.lp"

    # cleaning the file from previous runs <----------------------------
    existing_files = os.listdir("/mnt/c/Users/13365/OneDrive/桌面/Linux-Ubuntu/Among_us_scasp/data")
    if(len(existing_files ) >= 1):
        for file in existing_files:
            os.remove(os.path.join(local_path,file))

    # defining the set up of the game
    player_num = 5
    #player_num = random.randint(3,10)
    # 5 rooms available
    room_num = 5
    # the starting turn
    turn = 0
    # randomly generate a killer
    selected_killer = random.randint(1,player_num)

    # creating a file called set_up.lp to store the basic information
    set_up(player_num, room_num,selected_killer) # <------------------------------

    game_over = False
    print("Set up complete - now querying\n")
    while not game_over:
        # progressing the game
        turn += 1
        progress_turn(player_num, room_num, turn)              # <-----------------------------------

        # creating a dynamic files list for scasp to run as this code progresses
        rules_collection = os.listdir(local_path)
        for index in range(0, len(rules_collection)):
            rules_collection[index] = os.path.join(local_path,rules_collection[index]) # complete the address in the array

        run_line= [scasp,"-s1",query, rules] + rules_collection # the fun command line


        test = subprocess.Popen(run_line, stdout= subprocess.PIPE)
        out,e = test.communicate()
        out = out.decode("ASCII").rstrip().split("\n")
        game_over=parse_scasp_output(out)
        print(out, "\n")
        # for output in out:
        #     print(output,"\n")
        print("----------------------------\n" )
        print(e)




