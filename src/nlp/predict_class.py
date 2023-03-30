import joblib
import os
import sys

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

def predict_class(input_text):
    # Load the trained model
    filepath = os.path.join(BASE_DIR, 'multinomial_naive_bayesian_model.joblib')
    model = joblib.load(filepath)

    predicted_class = model.predict([input_text])
    if predicted_class[0] == 2:
        return 'Positive'
    elif predicted_class[0] == 1:
        return 'Neutral'
    else:
        return 'Negative'

predicted_class = predict_class(sys.argv[1])
print(predicted_class)