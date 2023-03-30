import { Body, Controller, Post } from "@nestjs/common";
import { AppService } from './app.service';
import { TwitDto } from "./dto/twit.dto";
import { SentimentAnalysisInterface } from "./interfaces/sentiment-analysis.interface";

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Post()
  async sentimentAnalyse(@Body() twitDto: TwitDto): Promise<SentimentAnalysisInterface> {
    return await this.appService.sentimentAnalyse(twitDto.twit);
  }
}
