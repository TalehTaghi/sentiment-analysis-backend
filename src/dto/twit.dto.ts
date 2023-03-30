import { IsNotEmpty, IsString } from "class-validator";

export class TwitDto {
  @IsString()
  @IsNotEmpty()
  twit!: string;
}