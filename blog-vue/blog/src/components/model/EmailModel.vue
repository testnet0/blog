<template>
  <v-dialog v-model="emailFlag" :fullscreen="isMobile" max-width="460">
    <v-card class="login-container" style="border-radius:4px">
      <v-icon class="float-right" @click="emailFlag = false">
        mdi-close
      </v-icon>
      <div class="login-wrapper">
        <!-- 用户名 -->
        <v-text-field v-model="email" label="邮箱号" placeholder="请输入您的邮箱号" clearable @keyup.enter="register" />
        <!-- 图形验证码 -->
        <div class="mt-7 in_code">
          <img id="imgCode" :src="'/api/captcha?timestamp=' + this.timestamp" @click="handleCaptcha" />
          <v-text-field v-model="captcha" maxlength="4" label="图形验证码" placeholder="请输入图形验证码" clearable />
        </div>
        <!-- 验证码 -->
        <div class="mt-7 send-wrapper">
          <v-text-field maxlength="6" v-model="code" label="验证码" placeholder="请输入6位验证码" @keyup.enter="register" />
          <v-btn text small :disabled="flag" @click="sendCode">
            {{ codeMsg }}
          </v-btn>
        </div>
        <!-- 按钮 -->
        <v-btn class="mt-7" block color="blue" style="color:#fff" @click="saveUserEmail">
          绑定
        </v-btn>
      </div>
    </v-card>
  </v-dialog>
</template>

<script>
export default {
  data: function () {
    return {
      email: this.$store.state.email,
      code: "",
      flag: true,
      codeMsg: "发送",
      time: 60,
      show: false,
      captcha: "",
      timestamp: new Date().getTime(),
    };
  },
  methods: {
    handleCaptcha() {
      this.timestamp = new Date().getTime();
      document.getElementById("imgCode").src = "/api/captcha?timestamp=" + this.timestamp;
    },
    sendCode() {
      const that = this;
      if (that.captcha.trim().length != 4) {
        that.$toast({ type: "error", message: "请输入4位图形验证码" });
        return false;
      }
      //发送邮件
      that.axios
        .get("/api/users/code", {
          params: { timestamp: that.timestamp, captcha: that.captcha, username: that.email }
        })
        .then(({ data }) => {
          if (data.flag) {
            that.$toast({ type: "success", message: data.message });
            that.countDown();
          } else {
            that.$toast({ type: "error", message: data.message });
            this.handleCaptcha();
          }
        });
    },
    countDown() {
      this.flag = true;
      this.timer = setInterval(() => {
        this.time--;
        this.codeMsg = this.time + "s";
        if (this.time <= 0) {
          clearInterval(this.timer);
          this.codeMsg = "发送";
          this.time = 60;
          this.flag = false;
        }
      }, 1000);
    },
    saveUserEmail() {
      var reg = /^[A-Za-z0-9\u4e00-\u9fa5]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$/;
      if (!reg.test(this.email)) {
        this.$toast({ type: "error", message: "邮箱格式不正确" });
        return false;
      }
      if (this.captcha.trim().length != 4) {
        this.$toast({ type: "error", message: "请输入4位图形验证码" });
        return false;
      }
      if (this.code.trim().length != 6) {
        this.$toast({ type: "error", message: "请输入6位邮箱验证码" });
        return false;
      }
      const user = {
        email: this.email,
        code: this.code,
        captcha: this.captcha,
        timestamp: this.timestamp,
      };
      this.axios.post("/api/users/email", user).then(({ data }) => {
        if (data.flag) {
          this.$store.commit("saveEmail", this.email);
          this.email = "";
          this.code = "";
          this.$store.commit("closeModel");
          this.$toast({ type: "success", message: data.message });
        } else {
          this.$toast({ type: "error", message: data.message });
          this.handleCaptcha();
        }
      });
    }
  },
  computed: {
    emailFlag: {
      set(value) {
        this.$store.state.emailFlag = value;
      },
      get() {
        return this.$store.state.emailFlag;
      }
    },
    isMobile() {
      const clientWidth = document.documentElement.clientWidth;
      if (clientWidth > 960) {
        return false;
      }
      return true;
    }
  },
  watch: {
    email(value) {
      var reg = /^[A-Za-z0-9\u4e00-\u9fa5]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$/;
      if (reg.test(value)) {
        this.flag = false;
      } else {
        this.flag = true;
      }
    }
  }
};
</script>

<style scoped>
@media (min-width: 760px) {
  .login-container {
    padding: 1rem;
    border-radius: 4px;
    height: 400px;
  }
}
</style>
