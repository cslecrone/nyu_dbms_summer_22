from dataclasses import dataclass
from typing import List
import warnings

from imblearn.over_sampling import RandomOverSampler
import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split, RandomizedSearchCV
from sklearn.preprocessing import LabelEncoder, StandardScaler

DEFAULT_DATASET = "../data/cancer/lung_cancer_survey.csv"

# Silence warnings
warnings.filterwarnings("ignore")


@dataclass
class SurveyData:
    """Input data for ML model"""

    age: int
    gender: bool
    smokes: bool
    fingers: bool
    anxiety: bool
    peer: bool
    chronic: bool
    fatigue: bool
    allergies: bool
    wheeze: bool
    alcohol: bool
    cough: bool
    breath: bool
    swallow: bool
    chest: bool

    def as_df(self):
        return {
            "GENDER": int(self.gender),
            "AGE": int(self.age),
            "SMOKING": int(self.smokes),
            "YELLOW_FINGERS": int(self.fingers),
            "ANXIETY": int(self.anxiety),
            "PEER_PRESSURE": int(self.peer),
            "CHRONIC DISEASE": int(self.chronic),
            "FATIGUE": int(self.fatigue),
            "ALLERGY": int(self.allergies),
            "WHEEZING": int(self.wheeze),
            "ALCOHOL CONSUMING": int(self.alcohol),
            "COUGHING": int(self.cough),
            "SHORTNESS OF BREATH": int(self.breath),
            "SWALLOWING DIFFICULTY": int(self.swallow),
            "CHEST PAIN": int(self.chest),
        }

    def as_array(self):
        arr = []
        arr.append(int(self.gender))
        arr.append(int(self.age))
        arr.append(int(self.smokes))
        arr.append(int(self.fingers))
        arr.append(int(self.anxiety))
        arr.append(int(self.peer))
        arr.append(int(self.chronic))
        arr.append(int(self.fatigue))
        arr.append(int(self.allergies))
        arr.append(int(self.wheeze))
        arr.append(int(self.alcohol))
        arr.append(int(self.cough))
        arr.append(int(self.breath))
        arr.append(int(self.swallow))
        arr.append(int(self.chest))

        return arr


def load_dataframe(dataset_path: str = DEFAULT_DATASET) -> pd.DataFrame:
    # Create a dataframe from our dataset and remove duplicates
    df = pd.read_csv(dataset_path)
    df.drop_duplicates(inplace=True)
    return df


def train_model(df: pd.DataFrame) -> RandomizedSearchCV:
    # Encode the Lung Cancer and Gender columns to binary values
    # M->1 F->0
    # YES->1 NO->0
    encoder = LabelEncoder()
    df["LUNG_CANCER"] = encoder.fit_transform(df["LUNG_CANCER"])
    df["GENDER"] = encoder.fit_transform(df["GENDER"])

    # Separate independent and dependent features
    x = df.drop(["LUNG_CANCER"], axis=1)
    y = df["LUNG_CANCER"]

    # Normalize 1's and 2's as 0's and 1's
    for i in x.columns[2:]:
        temp = []
        for j in x[i]:
            temp.append(j - 1)
        x[i] = temp

    # Oversample minority classes
    x_over, y_over = RandomOverSampler().fit_resample(x, y)

    # Split data into training and test datasets
    x_train, x_test, y_train, y_test = train_test_split(
        x_over, y_over, random_state=42, stratify=y_over
    )

    # Standardize Age data in both the training and test datasets
    scaler = StandardScaler()
    x_train["AGE"] = scaler.fit_transform(x_train[["AGE"]])
    x_test["AGE"] = scaler.transform(x_test[["AGE"]])

    param_grid = {
        "C": [0.001, 0.01, 0.1, 1, 10, 100],
        "max_iter": [50, 75, 100, 200, 300, 400, 500, 700],
    }

    # Train model on training data
    log = RandomizedSearchCV(LogisticRegression(solver="lbfgs"), param_grid, cv=5)
    log.fit(x_train, y_train)

    return log


def predict(log: RandomizedSearchCV, data: List[int]):
    result = log.predict(data)
    return result


def normalize_sample_data(data: SurveyData):
    df = load_dataframe()

    encoder = LabelEncoder()
    df["LUNG_CANCER"] = encoder.fit_transform(df["LUNG_CANCER"])
    df["GENDER"] = encoder.fit_transform(df["GENDER"])

    # Separate independent and dependent features
    x = df.drop(["LUNG_CANCER"], axis=1)
    y = df["LUNG_CANCER"]

    # Normalize 1's and 2's as 0's and 1's
    for i in x.columns[2:]:
        temp = []
        for j in x[i]:
            temp.append(j - 1)
        x[i] = temp

    # Oversample minority classes
    x_over, y_over = RandomOverSampler().fit_resample(x, y)

    # Split data into training and test datasets
    x_train, x_test, y_train, y_test = train_test_split(
        x_over, y_over, random_state=42, stratify=y_over
    )

    x_test.loc[-1] = data.as_array()
    x_test.index = x_test.index + 1

    # Standardize Age data in both the training and test datasets
    scaler = StandardScaler()
    x_train['AGE'] = scaler.fit_transform(x_train[['AGE']])
    x_test['AGE'] = scaler.transform(x_test[['AGE']])

    return x_test
