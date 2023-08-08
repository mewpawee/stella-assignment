""" 
Write a function solve(wordList, target) in Python3 to solve the following problem:
- Input:
- A list of distinct strings wordList - Target word target
- Output:
- Return 2 words (not necessarily distinct) that combined (concatenated) to the
target word. (Any pair is fine if multiple solutions exist). - If no pair exists, return None.
Examples:
1. wordList = [“ab”, “bc”, “cd”], target = “abcd”
⇒ output = (“ab”, “cd”) or (“cd”, “ab”)
2. wordList = [“ab”, “bc”, “cd”], target = “cdab”
⇒ output = (“ab”, “cd”) or (“cd”, “ab”)
3. wordList = [“ab”, “bc”, “cd”], target = “abab”
⇒ output = None
4. wordList = [“ab”, “ba”, “ab”], target = “abab” ⇒ output = (“ab”, “ab”)
"""

def solve(wordList: list[str], target: str) -> tuple[str] | None:
    target_length:int = len(target)

    if target_length != 4:
        return None

    index:int = 0
    matchList:list[str] = []

    # loop through the target with increment index by 2
    while(index < target_length-1):
        # get the current pair
        current:str = target[index:index+2]
        # find the match index, None if not found
        matched_index:int | None = wordList.index(current) if current in wordList else None
        if matched_index != None:
            matchList.append(wordList.pop(matched_index)) # pop and append to matchList
        # move to the next pair
        index += 2

    # return a matched pair. If there are no matched or partial matched, return None
    return tuple(matchList) if len(matchList) == 2 else None

def test1():
    test_1 =  ["ab","bc","cd"]
    target_1 = "abcd"
    answer_1 = solve(test_1,target_1)
    assert answer_1 == ("ab","cd"), 'should be ("ab","cd")'
    print("Test1 done!")

def test2():
    test_2 =  ["ab","bc","cd"]
    target_2 = "cdab"
    answer_2 = solve(test_2,target_2)
    assert answer_2 == ("cd","ab"), 'should be ("ab","cd")'
    print("Test2 done!")

def test3():
    test_3 =  ["ab","bc","cd"]
    target_3 = "abab"
    answer_3 = solve(test_3,target_3)
    assert answer_3 == None, 'should be None'
    print("Test3 done!")

def test4():
    test_4 = ["ab","ba","ab"]
    target_4 = "abab"
    answer_4 = solve(test_4,target_4)
    assert answer_4 == ("ab","ab")
    print("Test4 done!")

test1()
test2()
test3()
test4()
