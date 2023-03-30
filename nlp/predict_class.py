import joblib
import pickle as pkl
import os
import sys

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

vocabularyFilepath = os.path.join(BASE_DIR, 'vocabulary.pkl')
with open(vocabularyFilepath, 'rb') as f:
    vocabulary = pkl.load(f)

def isInVocabulary(word, voc=vocabulary):
    """
    Searchs for word from dictonary based on first letter
    """
    first_letter = word[0]
    if first_letter not in voc:
        return False
    if word in voc[first_letter]:
        return True
    else:
        return False

def stem(string):
    l=[]
    vowels=["a","ı","o","u","e","ə","i"]
    string=string.split()
    for i in string:
        if i.isupper() or (string.index(i)!=0 and i[0].isupper()):
            # xüsusi isimlər və abbr. üçün
            l.append(i)
        else:
            for j in range(len(i),0,-1):
                if isInVocabulary(i[:j].casefold()): # i[:j].casefold() in words:
                    # adi şəkilçilər üçün
                    l.append(i[:j])
                    break
                elif i[j-1] in vowels and (i[j-2]=="y" or i[j-2]=="ğ") :
                    # bitişdirici samitlər üçün
                    if isInVocabulary((i[:j-2]+"k").casefold()): # (i[:j-2]+"k").casefold() in words:
                        l.append(i[:j-2]+"k")
                        break
                    elif isInVocabulary((i[:j-2]+"q").casefold()): # (i[:j-2]+"q").casefold() in words:
                        l.append(i[:j-2]+"q")
                        break
    return ' '.join(l)

def predict_class(input_text):
    # Load the trained model
    joblibFilepath = os.path.join(BASE_DIR, 'multinomial_naive_bayesian_model.joblib')
    model = joblib.load(joblibFilepath)

    predicted_class = model.predict([input_text])
    if predicted_class[0] == 2:
        return 'Positive'
    elif predicted_class[0] == 1:
        return 'Neutral'
    else:
        return 'Negative'

print(predict_class(stem(sys.argv[1])))