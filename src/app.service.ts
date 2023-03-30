import { Injectable } from '@nestjs/common';
import { exec } from "child_process";
import { SentimentEnum } from "./enums/sentiment.enum";
import { SentimentAnalysisInterface } from "./interfaces/sentiment-analysis.interface";

@Injectable()
export class AppService {
  async sentimentAnalyse(twit: string): Promise<SentimentAnalysisInterface> {
    return new Promise<SentimentAnalysisInterface>((resolve, reject) => {
      exec(`python3 src/nlp/predict_class.py "${twit}"`, (error, stdout) => {
        if (error) {
          console.error(`exec error: ${error}`);
          reject(error);

          return;
        }

        const sentiment = stdout.trim().replace(/\n/g, '');

        resolve({
          sentiment,
          key: SentimentEnum[sentiment]
        });
      });
    });
  }
}
